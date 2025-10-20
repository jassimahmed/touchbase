//
//  ProfileView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
  let user: User
  
  @State private var showLoginView = false
  @State private var showNotifications = false
  @State private var selectedTab = "Family"  // Default tab for current user
  
  private var isCurrentUser: Bool {
    guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
    return currentUserId == user.id
  }
  
  private let tabs = ["Family", "Friends", "Colleagues", "Photos"]
  
  var body: some View {
    VStack(spacing: 20) {
      // MARK: - Profile Header
      Image("profile_pic")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .shadow(radius: 4)
        .background(.ultraThinMaterial, in: Circle())
      
      VStack(spacing: 4) {
        Text(user.name)
          .font(.title2.bold())
        Text("@\(user.username)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      
      // MARK: - Conditional Buttons
      if isCurrentUser {
        Button(action: signOut) {
          Text("Sign Out")
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.red)
            .cornerRadius(12)
            .shadow(radius: 3)
        }
        .padding(.horizontal)
      } else {
        AddRelationshipButton(user: user)
      }
      
      // MARK: - Tabs (only for current user)
      if isCurrentUser {
        VStack {
          Picker("Select Tab", selection: $selectedTab) {
            ForEach(tabs, id: \.self) { tab in
              Text(tab).tag(tab)
            }
          }
          .pickerStyle(.segmented)
          .padding(.horizontal)
          .padding(.top, 10)
          
          // Tab content
          Group {
            switch selectedTab {
            case "Family":
              FamilyTabView()
            case "Friends":
              FriendsTabView()
            case "Colleagues":
              ColleaguesTabView()
            case "Photos":
              PhotosTabView()
            default:
              EmptyView()
            }
          }
          .padding(.top, 8)
          .transition(.opacity)
        }
      }
      
      Spacer()
    }
    .padding()
    .navigationTitle(user.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if isCurrentUser {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: { showNotifications = true }) {
            Image(systemName: "envelope.badge")
              .font(.title2)
          }
        }
      }
    }
    .navigationDestination(isPresented: $showNotifications) {
      NotificationView()
    }
    .fullScreenCover(isPresented: $showLoginView) {
      LoginView()
    }
  }
  
  private func signOut() {
    do {
      try Auth.auth().signOut()
      showLoginView = true
    } catch {
      print("Error signing out: \(error.localizedDescription)")
    }
  }
}

// MARK: - Placeholder Tab Views

struct FamilyTabView: View {
  var body: some View {
    VStack {
      Text("Family connections will appear here.")
        .foregroundStyle(.secondary)
        .padding()
      Spacer()
    }
  }
}

struct FriendsTabView: View {
  var body: some View {
    VStack {
      Text("Friends connections will appear here.")
        .foregroundStyle(.secondary)
        .padding()
      Spacer()
    }
  }
}

struct ColleaguesTabView: View {
  var body: some View {
    VStack {
      Text("Colleagues connections will appear here.")
        .foregroundStyle(.secondary)
        .padding()
      Spacer()
    }
  }
}

struct PhotosTabView: View {
  var body: some View {
    VStack {
      Text("Your photos will appear here.")
        .foregroundStyle(.secondary)
        .padding()
      Spacer()
    }
  }
}

#Preview {
  NavigationStack {
    ProfileView(
      user: User(id: "1", name: "John Doe", username: "johndoe")
    )
  }
}
