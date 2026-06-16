import Combine
import Foundation
import UIKit

@MainActor
final class LiveAttendanceViewModel: ObservableObject {
    @Published var snapshot: LiveAttendanceDTO?
    @Published var timeRemaining: Int = 0
    @Published var errorMessage: String?
    @Published var isClosing = false
    @Published var didClose = false

    /// Notifica a View quando o app foi pro background no meio da chamada —
    /// usada pra mostrar alerta crítico de interrupção.
    @Published var didInterruptBroadcast: Bool = false

    let chamada: ChamadaCreatedDTO

    let broadcaster: BeaconBroadcaster
    let heartbeat: HeartbeatService

    private let totalStudentsFallback: Int
    private var pollingTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var lifecycleObservers: [NSObjectProtocol] = []

    init(chamada: ChamadaCreatedDTO, totalStudents: Int, durationMinutes: Int) {
        self.chamada = chamada
        self.totalStudentsFallback = totalStudents
        self.timeRemaining = durationMinutes * 60
        self.broadcaster = BeaconBroadcaster()
        self.heartbeat = HeartbeatService()
    }

    var idChamada: Int64 { chamada.idChamada }

    func start() {
        timerTask?.cancel()
        pollingTask?.cancel()

        // Garante que iPhone não dorme enquanto chamada está ativa.
        UIApplication.shared.isIdleTimerDisabled = true

        // Inicia broadcast iBeacon.
        if let uuid = UUID(uuidString: chamada.beaconUuid) {
            broadcaster.start(uuid: uuid,
                              major: UInt16(truncatingIfNeeded: chamada.beaconMajor),
                              minor: UInt16(truncatingIfNeeded: chamada.beaconMinor),
                              identifier: "qrollcall.chamada.\(chamada.idChamada)")
        } else {
            errorMessage = "UUID do beacon inválido — chamada não pode ser transmitida."
        }

        // Inicia heartbeat (5s).
        heartbeat.start(idChamada: chamada.idChamada)

        // Observa background/foreground.
        registerLifecycleObservers()

        timerTask = Task {
            while !Task.isCancelled && timeRemaining > 0 {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    if timeRemaining > 0 { timeRemaining -= 1 }
                }
            }
        }

        pollingTask = Task {
            while !Task.isCancelled {
                await refresh()
                try? await Task.sleep(nanoseconds: 2_500_000_000)
            }
        }
    }

    func stop() {
        timerTask?.cancel()
        pollingTask?.cancel()
        timerTask = nil
        pollingTask = nil
        broadcaster.stop()
        heartbeat.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        unregisterLifecycleObservers()
    }

    func refresh() async {
        do {
            let data = try await ChamadaService.live(idChamada)
            self.snapshot = data
            if data.timeRemainingSec > 0 {
                self.timeRemaining = Int(data.timeRemainingSec)
            } else if data.estado.uppercased().contains("INATIVO") {
                self.timeRemaining = 0
            }
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription
        }
    }

    func close(presentes: [Int64], ausentes: [Int64]) async {
        isClosing = true
        defer { isClosing = false }
        do {
            try await ChamadaService.encerrarComResumo(
                idChamada,
                resumo: EncerrarComResumoDTO(alunosPresentes: presentes, alunosAusentes: ausentes)
            )
            didClose = true
            stop()
        } catch is CancellationError {
            return

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível encerrar."
        }
    }

    /// Limpa a flag de interrupção depois que o usuário viu o alerta.
    func acknowledgeInterruption() {
        didInterruptBroadcast = false
    }

    var confirmados: [LiveAttendanceDTO.ConfirmadoDTO] {
        snapshot?.confirmados ?? []
    }

    var confirmedIds: Set<Int64> {
        Set(confirmados.map(\.alunoId))
    }

    var confirmedCount: Int { snapshot?.confirmedCount ?? confirmados.count }
    var totalStudents: Int { snapshot?.totalStudents ?? totalStudentsFallback }

    private func registerLifecycleObservers() {
        let bg = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                // Quando o app vai pro background, iOS pode pausar o advertise.
                // Sinalizamos interrupção pra View mostrar alerta crítico.
                self.didInterruptBroadcast = true
            }
        }

        let fg = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                // Ao voltar a foreground, reinicia broadcast (broadcaster lida com
                // ciclo do CBPeripheralManager internamente).
                if let uuid = UUID(uuidString: self.chamada.beaconUuid) {
                    self.broadcaster.start(uuid: uuid,
                                           major: UInt16(truncatingIfNeeded: self.chamada.beaconMajor),
                                           minor: UInt16(truncatingIfNeeded: self.chamada.beaconMinor),
                                           identifier: "qrollcall.chamada.\(self.chamada.idChamada)")
                }
            }
        }

        lifecycleObservers = [bg, fg]
    }

    private func unregisterLifecycleObservers() {
        for token in lifecycleObservers {
            NotificationCenter.default.removeObserver(token)
        }
        lifecycleObservers.removeAll()
    }
}
