//
//  AddRelationshipButton.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-12.
//

import SwiftUI

struct AddRelationshipButton: View {
  let user: User
  
  @State private var isExpanded = false
  @State private var requestSentType: String? = nil // "Friend" or "Family"
  
  var body: some View {
    VStack {
      if let type = requestSentType {
        // Show confirmation
        Text("\(type) request sent")
          .font(.subheadline.bold())
          .padding(.vertical, 10)
          .padding(.horizontal, 20)
          .background(.green.opacity(0.8))
          .foregroundStyle(.white)
          .cornerRadius(12)
          .shadow(radius: 2)
          .transition(.opacity.combined(with: .scale))
        
      } else if isExpanded {
        // Show two choices
        VStack(spacing: 10) {
          Button("Friend") {
            UserConnectionService.sendConnectionRequest(toUserId: user.id, type: "Friend") { success in
              if success {
                requestSentType = "Friend"
              }
            }
            isExpanded = false
          }
          .buttonStyle(AddChoiceStyle(color: .blue))
          
          Button("Family") {
            withAnimation(.spring()) {
              UserConnectionService.sendConnectionRequest(toUserId: user.id, type: "Family") { success in
                if success {
                  requestSentType = "Family"
                }
              }
              isExpanded = false
            }
          }
          .buttonStyle(AddChoiceStyle(color: .red))
        }
        .transition(.asymmetric(insertion: .scale.combined(with: .opacity),
                                removal: .opacity))
        
      } else {
        // Main "Add" button
        Button {
          withAnimation(.spring()) {
            isExpanded.toggle()
          }
        } label: {
          Text("Add")
            .font(.subheadline.bold())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(.blue.opacity(0.8))
            .foregroundStyle(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .transition(.opacity.combined(with: .scale))
      }
    }
  }
}

// Small helper for consistent style
struct AddChoiceStyle: ButtonStyle {
  var color: Color
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.subheadline.bold())
      .padding(.vertical, 10)
      .padding(.horizontal, 20)
      .background(color.opacity(configuration.isPressed ? 0.6 : 0.8))
      .foregroundStyle(.white)
      .cornerRadius(12)
      .shadow(radius: 2)
  }
}

//#Preview {
//  AddRelationshipButton()
//    .padding()
//    .previewLayout(.sizeThatFits)
//}
