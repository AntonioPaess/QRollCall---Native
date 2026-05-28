import Combine
import Foundation

@MainActor
final class ProfessorHistoryViewModel: ObservableObject {
    @Published var history: [ChamadaPassadaDTO] = []
    @Published var classes: [String] = []
    @Published var selectedFilter = "Todas"
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            history = try await ProfessorService.historico()
            classes = Array(Set(history.map(\.className))).sorted()
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }

    var filtered: [ChamadaPassadaDTO] {
        if selectedFilter == "Todas" { return history }
        return history.filter { $0.className == selectedFilter }
    }

    var availableFilters: [String] {
        ["Todas"] + classes
    }

    var totalPresent: Int { filtered.reduce(0) { $0 + $1.presentCount } }
    var totalStudents: Int { filtered.reduce(0) { $0 + $1.totalCount } }
    var averageRate: Int {
        guard totalStudents > 0 else { return 0 }
        return Int(round(Double(totalPresent) / Double(totalStudents) * 100))
    }
}

@MainActor
final class AttendanceDetailViewModel: ObservableObject {
    @Published var detalhe: ChamadaDetalheDTO?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(chamadaId: Int64) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            detalhe = try await ProfessorService.chamadaDetalhe(chamadaId)
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Não foi possível carregar."
        }
    }
}
