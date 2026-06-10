//
//  CoordenacaoTabView.swift
//  QRollCall
//
//  Usa o padrão iOS 26 (Liquid Glass): pill com as abas + bolinha separada para
//  busca, via Tab(role: .search). Nada de toolbar item de lupa nas telas.
//

import SwiftUI

enum CoordTab: Hashable {
    case home, cursos, materias, perfil
    case search
}

struct CoordenacaoTabView: View {
    @State private var selection: CoordTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("Home", systemImage: AppIcons.home, value: CoordTab.home) {
                CoordenacaoHomeView()
            }
            Tab("Cursos", systemImage: AppIcons.book, value: CoordTab.cursos) {
                CoordenacaoTurmasView()
            }
            Tab("Matérias", systemImage: AppIcons.doc, value: CoordTab.materias) {
                MateriasView()
            }
            Tab("Perfil", systemImage: AppIcons.profile, value: CoordTab.perfil) {
                CoordenacaoProfileView()
            }
            Tab(value: CoordTab.search, role: .search) {
                NavigationStack {
                    AlunoSearchContent()
                }
            }
        }
        .tint(AppColors.primary)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    CoordenacaoTabView()
        .environmentObject(AuthSession.shared)
}
