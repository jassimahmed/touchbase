//
//  NavigationView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-09.
//

import SwiftUI

struct NavigationView: View {
  @State private var selectedTab: Int = 1
  
  var body: some View {
    TabView(selection: $selectedTab) {
      NavigationStack {
        ProfileView()
      }
      .tabItem {
        Label("Profile", systemImage: "person.crop.circle")
      }
      .tag(0)
      
      NavigationStack {
        ChatListView()
      }
      .tabItem {
        Label("Chats", systemImage: "message.fill")
      }
      .tag(1)
      
      NavigationStack {
        SearchView()
      }
      .tabItem {
        Label("Search", systemImage: "magnifyingglass")
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


