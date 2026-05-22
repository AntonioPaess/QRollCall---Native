//
//  ContentView.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: AppIcons.home)
                    Text(AppStrings.tabHome)
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Image(systemName: AppIcons.history)
                    Text(AppStrings.tabHistory)
                }
                .tag(1)

            ProfileView()
                .tabItem {
                    Image(systemName: AppIcons.profile)
                    Text(AppStrings.tabProfile)
                }
                .tag(2)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
}
