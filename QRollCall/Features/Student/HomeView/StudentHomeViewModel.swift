import Combine
import Foundation

@MainActor
final class StudentHomeViewModel: ObservableObject {
    @Published var nextClass: ProximaAulaDTO?
    @Published var stats: EstatisticasAlunoDTO?
    @Published var activities: [AtividadeDTO] = []
    @Published var activeAttendances: [ChamadaAtivaDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        async let proxima = AlunoService.proximaAula()
        async let stat = AlunoService.estatisticas()
        async let acts = AlunoService.atividadesRecentes(limit: 5)
        async let ativas = AlunoService.chamadasAtivas()
        do {
            nextClass = try await proxima
            stats = try await stat
            activities = try await acts
            activeAttendances = try await ativas
        } catch is CancellationError {
            return

        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }

    /// Polling leve: só consulta chamadas ativas. Usado num loop curto para
    /// detectar instantaneamente quando o professor inicia a chamada (sem
    /// precisar de WebSocket). Silencioso — não muda isLoading nem errorMessage.
    func pollActiveAttendances() async {
        do {
            let ativas = try await AlunoService.chamadasAtivas()
            if ativas.map(\.id) != activeAttendances.map(\.id) {
                activeAttendances = ativas
            }
        } catch {
            // ignora silenciosamente — não polui a UI
        }
    }

    var hasActiveAttendance: Bool { !activeAttendances.isEmpty }
    var firstActiveAttendance: ChamadaAtivaDTO? { activeAttendances.first }
}
