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
  let isCurrentUser: Bool
  
  @State private var isFriendAdded = false
  @State private var showLoginView = false
  
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
      
      // Add Friend button (only if viewing someone else)
      if !isCurrentUser {
        AddRelationshipButton(user: user)
      } else {
        // Sign Out Button (only for current user)
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
      }
      
      Spacer()
    }
    .padding()
    .navigationTitle(user.name)
    .navigationBarTitleDisplayMode(.inline)
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
    user: User(id: "1", name: "John Doe", username: "johndoe"),
    isCurrentUser: true
  )
}
