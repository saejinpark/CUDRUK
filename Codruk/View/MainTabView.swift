//
//  MainTabView.swift
//  Codruk
//
//  Created by 박세진 on 5/31/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            
            ChapterListView()
                .tabItem {
                    Label("탐험", systemImage: "books.vertical")
                }
            
            SavedView()
                .tabItem {
                    Label("저장", systemImage: "bookmark")
                }
        }
    }
}
