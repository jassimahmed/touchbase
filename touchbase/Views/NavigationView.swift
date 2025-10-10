//
//  NavigationView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-09.
//

import SwiftUI

struct NavigationView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ChatListView()
            }
            .tabItem {
                Label("Chats", systemImage: "message.fill")
            }
            .tag(0)

            NavigationStack {
                Text("Other tab")
            }
            .tabItem {
                Label("Other", systemImage: "square.grid.2x2")
            }
            .tag(1)
          
            NavigationStack {
                Text("Search")
            }
            .tabItem {
                Label("Add", systemImage: "plus")
            }
            .tag(2)
        }
        // iOS 26 enhancements
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            // If you ever want an accessory (like a mini player), you can insert it here
            // For now you can leave this out or put a placeholder
            EmptyView()
        }
    }
}


