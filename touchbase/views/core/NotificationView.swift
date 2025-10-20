//
//  NotificationView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-15.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NotificationView: View {
  @State private var requests: [Connection] = []
  @State private var isLoading = true
  @State private var currentUserId: String? = Auth.auth().currentUser?.uid
  
  var body: some View {
    VStack {
      if isLoading {
        ProgressView("Loading notifications...")
          .padding()
      } else if requests.isEmpty {
        Text("No new friend requests.")
          .foregroundStyle(.secondary)
          .padding()
      } else {
        List {
          ForEach(requests, id: \.id) { request in
            NotificationRow(request: request, onAction: handleAction)
              .listRowSeparator(.hidden)
              .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
          }
        }
        .listStyle(.insetGrouped)
      }
    }
    .navigationTitle("Notifications")
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      loadRequests()
    }
  }
  
  // MARK: - Load pending friend requests
  private func loadRequests() {
    guard let userId = currentUserId else {
      isLoading = false
      return
    }
    
    UserConnectionService.fetchPendingRequests(for: userId) { fetchedRequests in
      self.requests = fetchedRequests
      self.isLoading = false
    }
  }
  
  // MARK: - Handle accept/reject actions
  private func handleAction(_ action: String, for request: Connection) {
    guard let requestId = request.id else { return }
    let db = Firestore.firestore()
    
    let newStatus = (action == "accept") ? "accepted" : "rejected"
    db.collection("connections").document(requestId).updateData(["status": newStatus]) { error in
      if let error = error {
        print("Error updating request: \(error.localizedDescription)")
      } else {
        // Remove from UI
        requests.removeAll { $0.id == request.id }
      }
    }
  }
}

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
        .buttonStyle(.plain) // ensures proper tap handling inside List
        
        Button {
          onAction("reject", request)
        } label: {
          Text("Reject")
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.3))
            .foregroundColor(.primary)
            .cornerRadius(8)
        }
        .buttonStyle(.plain) // ensures proper tap handling inside List
      }
    }
    .padding(.vertical, 6)
    .onAppear {
      fetchSenderName()
    }
  }
  
  // Fetch the name of the user who sent the request
  private func fetchSenderName() {
    Firestore.firestore().collection("users").document(request.fromUserId).getDocument { snapshot, _ in
      if let data = snapshot?.data(),
         let name = data["name"] as? String {
        senderName = name
      }
    }
  }
}

#Preview {
  NavigationStack {
    NotificationView()
  }
}
