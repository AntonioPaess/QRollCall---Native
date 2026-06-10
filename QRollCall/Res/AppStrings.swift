//
//  AppStrings.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import Foundation

enum AppStrings {

    // MARK: - App

    static let appName = "QrollCall"
    static let appSubtitle = "Presença inteligente"

    // MARK: - Onboarding

    static let skip = "Pular"
    static let continueButton = "Continuar"
    static let startButton = "Começar"

    static let onboardingQRTitle = "Escaneie o QR Code"
    static let onboardingQRDescription = "Aponte sua câmera para o código QR exibido pelo professor na sala de aula"

    static let onboardingFaceTitle = "Reconhecimento\nFacial"
    static let onboardingFaceDescription = "Sua presença é validada através do reconhecimento facial para garantir segurança"

    static let onboardingLocationTitle = "Confirmação\nAutomática"
    static let onboardingLocationDescription = "Localização e horário são verificados automaticamente.\nRápido e seguro!"

    // MARK: - Home

    static let greeting = "Olá,"
    static let scanQRCode = "Escanear QR Code"
    static let registerPresence = "Registrar presença"
    static let nextClass = "Próxima Aula"
    static let presence = "Presença"
    static let classes = "Aulas"
    static let absences = "Faltas"
    static let streak = "Sequência"
    static let confirmed = "confirmadas"
    static let thisSemester = "neste semestre"
    static let consecutiveDays = "dias seguidos"
    static let recentActivity = "Atividade Recente"

    // MARK: - History

    static let historyTitle = "Histórico"
    static let historySubtitle = "Suas presenças e faltas"
    static let allFilter = "Todas"
    static let presences = "Presenças"
    static let rate = "Taxa"

    // MARK: - Profile

    static let profileTitle = "Perfil"
    static let matricula = "Matrícula:"
    static let updateFacialRegistration = "Atualizar Cadastro Facial"
    static let lastUpdate = "Última atualização:"
    static let generalStats = "Estatísticas Gerais"
    static let presenceRate = "Taxa de Presença"
    static let confirmedClasses = "Aulas Confirmadas"
    static let consecutiveDaysProfile = "Dias Seguidos"
    static let settings = "Configurações"
    static let notifications = "Notificações"
    static let privacyLGPD = "Privacidade e LGPD"
    static let helpSupport = "Ajuda e Suporte"
    static let logout = "Sair da conta"
    static let appVersion = "QrollCall v2.0.1"

    // MARK: - Login

    static let loginTitle = "Bem-vindo ao"
    static let emailPlaceholder = "E-mail institucional"
    static let passwordPlaceholder = "Senha"
    static let loginButton = "Entrar"
    static let iAmProfessor = "Sou Professor"
    static let iAmStudent = "Sou Aluno"

    // MARK: - Professor Home

    static let startAttendance = "Iniciar Chamada"
    static let startAttendanceSubtitle = "Criar chamada para a turma"
    static let currentClass = "Aula Atual"
    static let averagePresence = "Presença média"
    static let classesGiven = "Aulas dadas"
    static let lastAttendances = "Últimas Chamadas"
    static let studentsPresent = "presentes"

    // MARK: - Create Attendance

    static let createAttendanceTitle = "Nova Chamada"
    static let selectClass = "Selecione a turma"
    static let classType = "Tipo de aula"
    static let firstClass = "1ª Aula"
    static let secondClass = "2ª Aula"
    static let conjugatedClasses = "Conjugadas"
    static let oneAbsence = "1 falta se ausente"
    static let twoAbsences = "2 faltas se ausente"
    static let gamificationWords = "Palavras da gamificação"
    static let gamificationPlaceholder = "Ex: array, ponteiro, memória"
    static let duration = "Duração"
    static let minutes = "minutos"
    static let startButton2 = "Iniciar Chamada"

    // MARK: - Live Attendance

    static let liveAttendanceTitle = "Chamada Ativa"
    static let studentsConfirmed = "confirmados"
    static let closeAttendance = "Encerrar Chamada"
    static let timeRemaining = "Tempo restante"

    // MARK: - Attendance Summary

    static let summaryTitle = "Resumo da Chamada"
    static let presentStudents = "Presentes"
    static let absentStudents = "Ausentes"
    static let conclude = "Concluir"

    // MARK: - Professor Classes

    static let classesTitle = "Turmas"
    static let students = "alunos"
    static let atRisk = "Em risco"
    static let belowMinimum = "Abaixo de 75%"
    static let studentsList = "Lista de Alunos"
    static let attendanceHistory = "Histórico de Chamadas"

    // MARK: - Professor History

    static let professorHistorySubtitle = "Suas chamadas realizadas"
    static let attendanceDetail = "Detalhe da Chamada"

    // MARK: - Professor Profile

    static let department = "Departamento"

    // MARK: - Professor Tabs

    static let tabClasses = "Turmas"

    // MARK: - Student Attendance

    static let outOfRangeTitle = "Fora do alcance"
    static let outOfRangeMessage = "Você está fora do alcance da sala de aula.\nAproxime-se para registrar sua presença."
    static let tryAgain = "Tentar novamente"
    static let gamificationTitle = "Prove que você está na aula!"
    static let gamificationSubtitle = "Selecione as palavras relacionadas ao tema da aula"
    static let confirm = "Confirmar"
    static let gamificationFailTitle = "Resposta incorreta"
    static let gamificationFailMessage = "Você pode tentar novamente em"
    static let seconds = "segundos"
    static let faceIDFailTitle = "Verificação falhou"
    static let faceIDFailMessage = "Não foi possível verificar sua identidade.\nTente novamente."
    static let presenceConfirmed = "Presença confirmada!"
    static let discipline = "Disciplina"
    static let schedule = "Horário"
    static let time = "Tempo"
    static let backToHome = "Voltar ao início"
    static let activeAttendance = "Chamada ativa!"
    static let tapToRegister = "Toque para registrar presença"

    // MARK: - Status

    static let present = "Presente"
    static let absent = "Ausente"
    static let justified = "Justificado"

    // MARK: - Tabs

    static let tabHome = "Home"
    static let tabHistory = "Histórico"
    static let tabProfile = "Perfil"
    static let tabTurmas = "Turmas"
    static let tabAbono = "Abono"
    static let tabMetricas = "Métricas"

    // MARK: - Coordenação

    static let coordHomeGreeting = "Coordenação"
    static let coordHomeSubtitle = "Visão geral das turmas"
    static let coordKpiAlunos = "Alunos"
    static let coordKpiTurmas = "Turmas"
    static let coordKpiEmRisco = "Em risco"
    static let coordKpiReprovados = "Reprovados"
    static let coordRecentTurmas = "Turmas ativas"
    static let coordEmptyTurmas = "Nenhuma turma criada ainda"
    static let coordCreateTurma = "Criar turma"
    static let coordTurmaName = "Nome da turma"
    static let coordTurmaSemestre = "Semestre (ex: 2024.1)"
    static let coordAddAlunos = "Adicionar alunos"
    static let coordAddMaterias = "Adicionar matérias"
    static let coordAlunosLista = "Alunos da turma"
    static let coordMateriasLista = "Matérias da turma"

    // MARK: - Abono

    static let abonoTitle = "Abono em Massa"
    static let abonoSubtitle = "Selecione faltas para abonar"
    static let abonoSelectAluno = "Selecione o aluno"
    static let abonoSelectMateria = "Filtrar por matéria"
    static let abonoMotivo = "Motivo do abono"
    static let abonoMotivoPlaceholder = "Ex: atestado médico, atividade externa..."
    static let abonoByDates = "Abonar por período"
    static let abonoByList = "Abonar por seleção"
    static let abonoDataInicio = "Data início"
    static let abonoDataFim = "Data fim"
    static let abonoConfirm = "Confirmar abono"
    static let abonoSelected = "selecionada(s)"
    static let abonoEmptyState = "Sem faltas no período"
    static let abonoSuccess = "Abono registrado"

    // MARK: - Métricas

    static let metricasTitle = "Métricas"
    static let metricasFaltas = "faltas"
    static let metricasDe = "de"
    static let statusOk = "Em dia"
    static let statusAlerta = "Atenção"
    static let statusEmRisco = "Em risco"
    static let statusReprovado = "Reprovado"

    // MARK: - History (extra)

    static let historyByMateria = "Por matéria"
    static let historyAllAttendances = "Todas as chamadas"
    static let historyLimitLabel = "Limite"
    static let historyFaltasShort = "Faltas"
}
