import Combine
import Foundation

@MainActor
final class StudentHistoryViewModel: ObservableObject {
    @Published var summary: HistoricoSummaryDTO?
    @Published var entries: [HistoricoEntryDTO] = []
    @Published var filter: HistoryFilter = .todas
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
            let data = try await AlunoService.historico(filtro: raw)
            summary = data.summary
            entries = data.entries
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }
}
