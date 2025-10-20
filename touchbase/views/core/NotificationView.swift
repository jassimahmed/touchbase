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
  
  private func handleAction(_ action: String, for request: Connection) {
    guard let fromUserId = request.fromUserId as String? else { return }
    
    switch action {
    case "accept":
      UserConnectionService.acceptConnectionRequest(fromUserId: fromUserId) { success in
        if success {
          requests.removeAll { $0.id == request.id }
        }
      }
      
    case "delete":
      UserConnectionService.deleteConnectionRequest(fromUserId: fromUserId) { success in
        if success {
          requests.removeAll { $0.id == request.id }
        }
      }
      
    default:
      break
    }
  }
}

#Preview {
  NavigationStack {
    NotificationView()
  }
}
