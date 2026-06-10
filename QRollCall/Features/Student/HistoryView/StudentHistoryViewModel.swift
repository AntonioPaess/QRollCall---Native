import Combine
import Foundation

enum HistoryViewMode: String, CaseIterable, Identifiable {
    case porMateria
    case todas

    var id: String { rawValue }
    var label: String {
        switch self {
        case .porMateria: return AppStrings.historyByMateria
        case .todas:      return AppStrings.historyAllAttendances
        }
    }
}

@MainActor
final class StudentHistoryViewModel: ObservableObject {
    @Published var summary: HistoricoSummaryDTO?
    @Published var entries: [HistoricoEntryDTO] = []
    @Published var filter: HistoryFilter = .todas
    @Published var viewMode: HistoryViewMode = .porMateria
    @Published var faltasPorMateria: [FaltasPorMateriaDTO] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let raw: String
            switch filter {
            case .todas: raw = "todas"
            case .presente: raw = "presente"
            case .ausente: raw = "ausente"
            }
            async let historicoTask = AlunoService.historico(filtro: raw)
            async let faltasTask = MetricasService.minhasFaltas()
            let data = try await historicoTask
            summary = data.summary
            entries = data.entries
            do {
                faltasPorMateria = try await faltasTask
            } catch {
                faltasPorMateria = []
            }
        } catch is CancellationError {
            return
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }
}
