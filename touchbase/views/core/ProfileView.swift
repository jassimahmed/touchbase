//
//  ProfileView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
  let user: User        // The user being displayed
  
  @State private var isFriendAdded = false
  @State private var showLoginView = false
  @State private var showNotifications = false
  
  private var isCurrentUser: Bool {
    guard let currentUserId = Auth.auth().currentUser?.uid else { return false }
    return currentUserId == user.id
  }
  
  var body: some View {
    VStack(spacing: 20) {
      // Profile Image
      Image("profile_pic") // Replace later with remote image if needed
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 100, height: 100)
        .clipShape(Circle())
        .shadow(radius: 4)
        .background(.ultraThinMaterial, in: Circle())
      
      // Name and username
      VStack(spacing: 4) {
        Text(user.name)
          .font(.title2.bold())
        Text("@\(user.username)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }
      
      // MARK: - Conditional Buttons
      if isCurrentUser {
        // Sign Out Button (for current user)
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
        // Add Friend button (for other users)
        AddRelationshipButton(user: user)
      }
      
      Spacer()
    }
    .padding()
    .navigationTitle(user.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if isCurrentUser {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showNotifications = true
          }) {
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

#Preview {
  ProfileView(
    user: User(id: "1", name: "John Doe", username: "johndoe")
  )
}
