//
//  ProfileView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI

struct ProfileView: View {
    // State for Add Friend button
    @State private var isFriendAdded = false

    var profileImage: String = "profile_pic" // Your image asset
    var name: String = "John Doe"
    var username: String = "@johndoe"
    
    var body: some View {
        HStackLayout(alignment: .center, spacing: 16) {
            // Profile Image
            Image(profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .shadow(radius: 4)
                .background(.ultraThinMaterial, in: Circle())
            
            // Name and Username
            VStackLayout(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.title3.bold())
                Text(username)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Add Friend Button
            Button {
                isFriendAdded.toggle()
            } label: {
                Text(isFriendAdded ? "Friend Added" : "Add Friend")
                    .font(.subheadline.bold())
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(isFriendAdded ? .green.opacity(0.8) : .blue.opacity(0.8))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(20)
        .padding()
    }
}

#Preview {
    ProfileView()
        .previewLayout(.sizeThatFits)
}
