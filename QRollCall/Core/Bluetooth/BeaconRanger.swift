import Combine
import Foundation
import CoreLocation

/// Procura o beacon do professor e devolve uma leitura ESTATÍSTICA (não single-shot).
///
/// Estratégia de precisão:
///  1. Ranging contínuo por até `maxScanDuration` segundos (default 10s).
///  2. Coleta amostras a cada ~1s (frequência do CoreLocation).
///  3. Filtra amostras `unknown` ou `accuracy < 0`.
///  4. Critério de sucesso: pelo menos `minValidSamples` amostras válidas
///     com `proximity ∈ {immediate, near}` E `accuracy <= threshold` em
///     pelo menos `minValidSamples` das últimas `windowSize` amostras.
///  5. Reporta a MEDIANA do `accuracy` (resistente a outliers de reflexão).
///
/// Se o aluno não atinge o critério no tempo, retorna `.timeout` — o caller
/// decide entre tentar de novo ou mostrar OutOfRange.
@MainActor
final class BeaconRanger: NSObject, ObservableObject {

    struct Reading: Equatable {
        let proximity: String     // "immediate" | "near" | "far" | "unknown"
        let accuracy: Double      // metros; mediana das amostras válidas
        let validSamples: Int
        let totalSamples: Int
    }

    enum ScanResult: Equatable {
        case success(Reading)
        case timeout(Reading)
        case denied(String)
        case unsupported(String)
    }

    @Published private(set) var currentReading: Reading?

    // Parâmetros calibráveis. Padrões conservadores: cobre sala de aula
    // típica sem pegar corredor adjacente.
    private let proximityThresholdMeters: Double
    private let windowSize: Int
    private let minValidSamples: Int
    private let maxScanDuration: TimeInterval

    private var manager: CLLocationManager?
    private var beaconConstraint: CLBeaconIdentityConstraint?
    private var continuation: CheckedContinuation<ScanResult, Never>?
    private var startedAt: Date?
    private var samples: [CLBeacon] = []
    private var didFinish = false

    init(proximityThresholdMeters: Double = 5.0,
         windowSize: Int = 10,
         minValidSamples: Int = 8,
         maxScanDuration: TimeInterval = 10) {
        self.proximityThresholdMeters = proximityThresholdMeters
        self.windowSize = windowSize
        self.minValidSamples = minValidSamples
        self.maxScanDuration = maxScanDuration
        super.init()
    }

    /// Faz scan e devolve resultado. Apenas UMA chamada por instância em paralelo.
    func scan(uuid: UUID, major: UInt16?, minor: UInt16?) async -> ScanResult {
        let constraint: CLBeaconIdentityConstraint
        if let major = major, let minor = minor {
            constraint = CLBeaconIdentityConstraint(uuid: uuid, major: major, minor: minor)
        } else if let major = major {
            constraint = CLBeaconIdentityConstraint(uuid: uuid, major: major)
        } else {
            constraint = CLBeaconIdentityConstraint(uuid: uuid)
        }
        self.beaconConstraint = constraint

        let mgr = CLLocationManager()
        self.manager = mgr
        mgr.delegate = self

        // Ranging exige permissão de localização mesmo sem GPS.
        if mgr.authorizationStatus == .notDetermined {
            mgr.requestWhenInUseAuthorization()
        }

        return await withCheckedContinuation { (cont: CheckedContinuation<ScanResult, Never>) in
            self.continuation = cont
            self.samples.removeAll()
            self.didFinish = false
            self.startedAt = Date()

            switch mgr.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.beginRanging(constraint: constraint)
            case .denied, .restricted:
                self.finish(.denied("Permissão de localização negada"))
            default:
                // notDetermined: o callback `locationManagerDidChangeAuthorization`
                // dispara o ranging assim que o usuário decidir.
                break
            }
        }
    }

    func stop() {
        guard let mgr = manager, let constraint = beaconConstraint else { return }
        mgr.stopRangingBeacons(satisfying: constraint)
    }

    private func beginRanging(constraint: CLBeaconIdentityConstraint) {
        guard CLLocationManager.isRangingAvailable() else {
            finish(.unsupported("Este aparelho não suporta ranging de beacon"))
            return
        }
        manager?.startRangingBeacons(satisfying: constraint)

        // Watchdog de timeout — termina mesmo se nunca achar o beacon.
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            try? await Task.sleep(nanoseconds: UInt64(self.maxScanDuration * 1_000_000_000))
            if !self.didFinish {
                let reading = self.computeReading()
                self.finish(.timeout(reading))
            }
        }
    }

    private func ingest(_ beacons: [CLBeacon]) {
        // CoreLocation devolve uma lista com TODOS os beacons que casam com o constraint.
        // Como o UUID é único por chamada, devemos ter no máximo 1.
        guard let beacon = beacons.first else {
            // Lista vazia = visto fora de alcance neste tick. Conta como amostra inválida.
            return
        }
        samples.append(beacon)
        let reading = computeReading()
        self.currentReading = reading
        if isReadingValid(reading) {
            finish(.success(reading))
        }
    }

    private func computeReading() -> Reading {
        let window = samples.suffix(windowSize)
        let valid = window.filter { isSampleValid($0) }
        let accuracies = valid.map { $0.accuracy }.sorted()
        let median: Double = {
            guard !accuracies.isEmpty else { return -1 }
            let mid = accuracies.count / 2
            if accuracies.count % 2 == 0 {
                return (accuracies[mid - 1] + accuracies[mid]) / 2.0
            } else {
                return accuracies[mid]
            }
        }()
        let dominantProximity = mostFrequentProximity(in: valid)
        return Reading(
            proximity: dominantProximity,
            accuracy: median,
            validSamples: valid.count,
            totalSamples: window.count
        )
    }

    private func isSampleValid(_ beacon: CLBeacon) -> Bool {
        beacon.proximity != .unknown && beacon.accuracy >= 0
    }

    private func isReadingValid(_ reading: Reading) -> Bool {
        reading.validSamples >= minValidSamples
            && reading.accuracy >= 0
            && reading.accuracy <= proximityThresholdMeters
            && (reading.proximity == "immediate" || reading.proximity == "near")
    }

    private func mostFrequentProximity(in beacons: [CLBeacon]) -> String {
        var counts: [String: Int] = [:]
        for b in beacons {
            counts[Self.proximityString(b.proximity), default: 0] += 1
        }
        return counts.max(by: { $0.value < $1.value })?.key ?? "unknown"
    }

    static func proximityString(_ p: CLProximity) -> String {
        switch p {
        case .immediate: return "immediate"
        case .near:      return "near"
        case .far:       return "far"
        case .unknown:   return "unknown"
        @unknown default: return "unknown"
        }
    }

    private func finish(_ result: ScanResult) {
        guard !didFinish else { return }
        didFinish = true
        stop()
        continuation?.resume(returning: result)
        continuation = nil
    }
}

extension BeaconRanger: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor [weak self] in
            guard let self = self, let constraint = self.beaconConstraint else { return }
            switch manager.authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                self.beginRanging(constraint: constraint)
            case .denied, .restricted:
                self.finish(.denied("Permissão de localização negada"))
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didRange beacons: [CLBeacon],
                                     satisfying constraint: CLBeaconIdentityConstraint) {
        Task { @MainActor [weak self] in
            self?.ingest(beacons)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager,
                                     didFailRangingFor constraint: CLBeaconIdentityConstraint,
                                     error: Error) {
        Task { @MainActor [weak self] in
            self?.finish(.unsupported(error.localizedDescription))
        }
    }
}
