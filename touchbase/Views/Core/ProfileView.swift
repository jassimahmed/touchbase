//
//  ProfileView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI

struct ProfileView: View {
  let user: User        // The user being displayed
  let isCurrentUser: Bool
  
  @State private var isFriendAdded = false
  
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
      }
      
      Spacer()
    }
    .padding()
    .navigationTitle(user.name)
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  ProfileView(
    user: User(id: "1", name: "John Doe", username: "johndoe"),
    isCurrentUser: false
  )
}
