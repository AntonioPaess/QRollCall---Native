//
//  ContentView.swift
//  QRollCall
//

import SwiftUI

struct ContentView: View {

    enum Tab: Hashable {
        case home, history, profile
        case search
    }

    @State private var selection: Tab = .home

    var body: some View {
        TabView(selection: $selection) {
            SwiftUI.Tab(AppStrings.tabHome, systemImage: AppIcons.home, value: Tab.home) {
                HomeView()
            }
            SwiftUI.Tab(AppStrings.tabHistory, systemImage: AppIcons.history, value: Tab.history) {
                HistoryView()
            }
            SwiftUI.Tab(AppStrings.tabProfile, systemImage: AppIcons.profile, value: Tab.profile) {
                ProfileView()
            }
            SwiftUI.Tab(value: Tab.search, role: .search) {
                NavigationStack {
                    StudentSearchContent()
                }
            }
        }
        .tint(AppColors.primary)
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
}
