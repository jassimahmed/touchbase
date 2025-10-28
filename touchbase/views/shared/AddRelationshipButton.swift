//
//  AddRelationshipButton.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-12.
//

import SwiftUI
import FirebaseAuth
import os

struct AddRelationshipButton: View {
  let user: User                     // The profile user being viewed
  
  @State private var isExpanded = false
  @State private var requestStatus: String? = nil   // "sent", "received", or nil
  @State private var requestType: String? = nil     // "Friend", "Family", etc.
  @State private var connection: Connection? = nil
  
  // Convenience computed property for current user ID
  private var currentUserId: String? {
    Auth.auth().currentUser?.uid
  }
  
  var body: some View {
    VStack {
      if let status = requestStatus {
        switch status {
        case "sent":
          Text("\(requestType ?? "") request sent")
            .font(.subheadline.bold())
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(.gray.opacity(0.7))
            .foregroundStyle(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
            .disabled(true)
          
        case "received":
          if let connection = connection {
            HStack(spacing: 10) {
              Button("Accept") {
                UserConnectionService.acceptConnectionRequest(connection: connection) { success in
                  if success {
                    requestStatus = nil
                  }
                }
              }
              .buttonStyle(AddChoiceStyle(color: .green))
              
              Button("Delete") {
                UserConnectionService.deleteConnectionRequest(connection: connection) { success in
                  if success {
                    requestStatus = nil
                  }
                }
              }
              .buttonStyle(AddChoiceStyle(color: .red))
            }
          }
        default:
          EmptyView()
        }
        
      } else if let existingType = existingConnectionType() {
        // Show existing connection button with type-specific color and icon
        HStack {
          Image(systemName: iconForType(existingType))
            .font(.caption)
          Text(existingType)
            .font(.subheadline.bold())
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(colorForType(existingType).opacity(0.8))
        .foregroundStyle(.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        
      } else if isExpanded {
        VStack(spacing: 10) {
          Button("Friend") { sendRequest(type: "Friend") }
            .buttonStyle(AddChoiceStyle(color: .blue))
          
          Button("Family") { sendRequest(type: "Family") }
            .buttonStyle(AddChoiceStyle(color: .orange))
          
          Button("Colleague") { sendRequest(type: "Colleague") }
            .buttonStyle(AddChoiceStyle(color: .purple))
        }
        .transition(.scale.combined(with: .opacity))
        
      } else {
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
      }
    }
    .onAppear {
      checkConnectionStatus()
    }
  }
  
  // MARK: - Helper Methods
  
  private func checkConnectionStatus() {
    guard let currentUserId = currentUserId else { return }
    
    let cache = ConnectionCache.shared.connections
    
    if let sentConn = cache.first(where: { $0.fromUserId == currentUserId && $0.toUserId == user.id && $0.status == "pending" }) {
      requestStatus = "sent"
      requestType = sentConn.type
      connection = sentConn
    } else if let receivedConn = cache.first(where: { $0.toUserId == currentUserId && $0.fromUserId == user.id && $0.status == "pending" }) {
      requestStatus = "received"
      requestType = receivedConn.type
      connection = receivedConn
    }
  }
  
  private func sendRequest(type: String) {
    UserConnectionService.sendConnectionRequest(toUserId: user.id, type: type) { success in
      if success {
        requestStatus = "sent"
        requestType = type
        isExpanded = false
      }
    }
  }
  
  private func existingConnectionType() -> String? {
    guard let currentUserId = currentUserId else { return nil }
    
    // Get all accepted connections with this user
    let connections = ConnectionCache.shared.connections.filter {
      ($0.fromUserId == currentUserId && $0.toUserId == user.id) ||
      ($0.toUserId == currentUserId && $0.fromUserId == user.id)
    }.filter { $0.status == "accepted" }
    
    // Print for debugging
    for conn in connections {
      print("Connection: from \(conn.fromUserId) to \(conn.toUserId), type: \(conn.type), status: \(conn.status)")
    }
    
    // Return the first type, as before
    return connections.first?.type
  }
  
  private func colorForType(_ type: String) -> Color {
    switch type {
    case "Friend": return .blue
    case "Family": return .orange
    case "Colleague": return .purple
    default: return .gray
    }
  }
  
  private func iconForType(_ type: String) -> String {
    switch type {
    case "Friend": return "person.fill"
    case "Family": return "house.fill"
    case "Colleague": return "briefcase.fill"
    default: return "person.fill"
    }
  }
}

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

