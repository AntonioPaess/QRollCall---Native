//
//  ProfessorTabView.swift
//  QRollCall
//
//  Created by Antônio Paes on 15/04/26.
//

import SwiftUI

struct ProfessorTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ProfessorHomeView()
                .tabItem {
                    Image(systemName: AppIcons.home)
                    Text(AppStrings.tabHome)
                }
                .tag(0)

            ClassesView()
                .tabItem {
                    Image(systemName: AppIcons.classes)
                    Text(AppStrings.tabClasses)
                }
                .tag(1)

            ProfessorHistoryView()
                .tabItem {
                    Image(systemName: AppIcons.history)
                    Text(AppStrings.tabHistory)
                }
                .tag(2)

            ProfessorProfileView()
                .tabItem {
                    Image(systemName: AppIcons.profile)
                    Text(AppStrings.tabProfile)
                }
                .tag(3)
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ProfessorTabView()
}
