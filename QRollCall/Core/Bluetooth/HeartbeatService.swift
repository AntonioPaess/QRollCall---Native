import Combine
import Foundation

/// Pinga o backend a cada `interval` segundos enquanto a chamada está aberta.
/// Backend bloqueia novas presenças se não receber heartbeat por > 15s
/// (ver `PresencaService.HEARTBEAT_TIMEOUT_SECONDS` no Java).
///
/// O heartbeat NÃO é necessário pro broadcast iBeacon funcionar — ele só
/// garante que o backend saiba que o prof está ativo. Falha de rede aqui
/// não derruba o broadcast, mas faz alunos serem rejeitados ao registrar.
@MainActor
final class HeartbeatService: ObservableObject {

    @Published private(set) var lastSentAt: Date?
    @Published private(set) var lastErrorMessage: String?
    @Published private(set) var isRunning: Bool = false

    private let interval: TimeInterval
    private var task: Task<Void, Never>?

    init(interval: TimeInterval = 5) {
        self.interval = interval
    }

    func start(idChamada: Int64) {
        stop()
        isRunning = true
        task = Task { [weak self] in
            guard let self = self else { return }
            // Primeiro tick imediato para o backend saber assim que o prof inicia.
            await self.tick(idChamada: idChamada)
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(self.interval * 1_000_000_000))
                if Task.isCancelled { break }
                await self.tick(idChamada: idChamada)
            }
        }
    }

    func stop() {
        task?.cancel()
        task = nil
        isRunning = false
    }

    private func tick(idChamada: Int64) async {
        do {
            try await ChamadaService.heartbeat(idChamada)
            self.lastSentAt = Date()
            self.lastErrorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            self.lastErrorMessage = (error as? LocalizedError)?.errorDescription
                ?? "Falha ao enviar heartbeat"
        }
    }
}
