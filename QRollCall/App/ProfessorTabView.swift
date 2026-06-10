//
//  ProfessorTabView.swift
//  QRollCall
//

import SwiftUI

struct ProfessorTabView: View {

    enum Tab: Hashable {
        case home, classes, history, profile
        case search
    }

    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {
            SwiftUI.Tab("Home", systemImage: AppIcons.home, value: Tab.home) {
                ProfessorHomeView()
            }
            SwiftUI.Tab(AppStrings.tabClasses, systemImage: AppIcons.classes, value: Tab.classes) {
                ClassesView()
            }
            SwiftUI.Tab(AppStrings.tabHistory, systemImage: AppIcons.history, value: Tab.history) {
                ProfessorHistoryView()
            }
            SwiftUI.Tab(AppStrings.tabProfile, systemImage: AppIcons.profile, value: Tab.profile) {
                ProfessorProfileView()
            }
            SwiftUI.Tab(value: Tab.search, role: .search) {
                NavigationStack {
                    ProfessorSearchContent()
                }
            }
        }
        .tint(AppColors.primary)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ProfessorTabView()
}
