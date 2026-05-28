import Combine
import Foundation

@MainActor
final class LiveAttendanceViewModel: ObservableObject {
    @Published var snapshot: LiveAttendanceDTO?
    @Published var timeRemaining: Int = 0
    @Published var errorMessage: String?
    @Published var isClosing = false
    @Published var didClose = false

    private let idChamada: Int64
    private let totalStudentsFallback: Int
    private var pollingTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?

    init(idChamada: Int64, totalStudents: Int, durationMinutes: Int) {
        self.idChamada = idChamada
        self.totalStudentsFallback = totalStudents
        self.timeRemaining = durationMinutes * 60
    }

    func start() {
        timerTask?.cancel()
        pollingTask?.cancel()

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

    var confirmados: [LiveAttendanceDTO.ConfirmadoDTO] {
        snapshot?.confirmados ?? []
    }

    var confirmedIds: Set<Int64> {
        Set(confirmados.map(\.alunoId))
    }

    var confirmedCount: Int { snapshot?.confirmedCount ?? confirmados.count }
    var totalStudents: Int { snapshot?.totalStudents ?? totalStudentsFallback }
}
