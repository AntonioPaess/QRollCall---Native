import Combine
import Foundation
import CoreLocation
import CoreBluetooth

/// Anuncia o iPhone do professor como um iBeacon enquanto a chamada está ativa.
/// Cada chamada usa um UUID único vindo do backend para evitar replay/spoof.
///
/// LIMITAÇÕES iOS:
///  - iOS NÃO permite advertise de iBeacon em background pra apps comuns.
///    O `bluetooth-peripheral` background mode estende o tempo mas não garante.
///    Por isso: a UI obriga o prof a manter a tela aberta + `isIdleTimerDisabled=true`.
///  - Quando o app vai pro background, o sistema PODE pausar o advertise.
///    Detectamos via callback `peripheralManagerDidUpdateState` quando voltamos
///    a foreground e reiniciamos automaticamente.
@MainActor
final class BeaconBroadcaster: NSObject, ObservableObject {

    enum State: Equatable {
        case idle
        case waitingForBluetooth
        case advertising
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var isPoweredOn: Bool = false

    private var peripheralManager: CBPeripheralManager?
    private var pendingBeaconData: [String: Any]?

    /// Inicia o broadcast com os parâmetros vindos do backend.
    /// - Parameters:
    ///   - uuid: UUID único da chamada (vem do `ChamadaCreatedDTO.beaconUuid`)
    ///   - major: identifica a "região" — pode ser usado pra debugging
    ///   - minor: identifica a chamada específica
    ///   - identifier: ID local da região (apenas pra logging do CoreLocation)
    func start(uuid: UUID, major: UInt16, minor: UInt16, identifier: String) {
        stop()

        let region = CLBeaconRegion(uuid: uuid,
                                    major: major,
                                    minor: minor,
                                    identifier: identifier)
        // measuredPower padrão da Apple: -59 dBm a 1m. Bom o suficiente p/ ranging.
        let data = region.peripheralData(withMeasuredPower: nil) as NSDictionary
        pendingBeaconData = data as? [String: Any]

        state = .waitingForBluetooth
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }

    func stop() {
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
        pendingBeaconData = nil
        state = .idle
    }
}

extension BeaconBroadcaster: CBPeripheralManagerDelegate {
    nonisolated func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        Task { @MainActor in
            self.isPoweredOn = peripheral.state == .poweredOn

            switch peripheral.state {
            case .poweredOn:
                guard let data = self.pendingBeaconData else { return }
                peripheral.startAdvertising(data)
                self.state = .advertising
            case .poweredOff:
                self.state = .failed("Bluetooth desligado")
            case .unauthorized:
                self.state = .failed("Permissão de Bluetooth negada")
            case .unsupported:
                self.state = .failed("Bluetooth não suportado neste dispositivo")
            case .resetting:
                self.state = .waitingForBluetooth
            default:
                self.state = .waitingForBluetooth
            }
        }
    }

    nonisolated func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        Task { @MainActor in
            if let error = error {
                self.state = .failed(error.localizedDescription)
            } else {
                self.state = .advertising
            }
        }
    }
}
