//
//  NavigationView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-09.
//

import SwiftUI

struct NavigationView: View {
  @State private var selectedTab: Int = 1
  @State private var currentUser: User? = nil
  @State private var isLoadingUser = true
  
  var body: some View {
    TabView(selection: $selectedTab) {
      
      NavigationStack {
        if isLoadingUser {
          ProgressView("Loading profile…")
        } else if let user = currentUser {
          ProfileView(user: user)
        } else {
          Text("No logged-in user found")
            .foregroundStyle(.secondary)
        }
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
    .onAppear {
      fetchCurrentUser()
    }
  }
  
  private func fetchCurrentUser() {
    AuthService.getCurrentUser { user in
      self.currentUser = user
      self.isLoadingUser = false
    }
  }
}
