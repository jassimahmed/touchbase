//
//  NotificationRow.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-20.
//

import SwiftUI
import FirebaseFirestore

struct NotificationRow: View {
  let request: Connection
  let onAction: (String, Connection) -> Void
  
  @State private var senderName: String = ""
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(senderName.isEmpty ? "Loading..." : senderName)
            .font(.headline)
          Text("sent you a " + request.type.lowercased() + " request")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Spacer()
      }
      
      HStack(spacing: 12) {
        Button {
          onAction("accept", request)
        } label: {
          Text("Accept")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        
        Button {
          onAction("delete", request)
        } label: {
          Text("Delete")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.vertical, 6)
    .onAppear {
      fetchSenderName()
    }
  }
  
  private func fetchSenderName() {
    Firestore.firestore().collection("users").document(request.fromUserId).getDocument { snapshot, _ in
      if let data = snapshot?.data(),
         let name = data["name"] as? String {
        senderName = name
      }
    }
  }
}
