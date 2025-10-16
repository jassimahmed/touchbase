//
//  ConnectionService.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-12.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

struct UserConnectionService {
  static let db = Firestore.firestore()
  
  static func sendConnectionRequest(toUserId: String, type: String, completion: @escaping (Bool) -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
      completion(false)
      return
    }
    
    let connection = Connection(
      id: nil,
      fromUserId: currentUserId,
      toUserId: toUserId,
      type: type,
      status: "pending",
      timestamp: Date()
    )
    
    do {
      _ = try db.collection("connections").addDocument(from: connection) { error in
        if let error = error {
          print("Error sending connection request: \(error.localizedDescription)")
          completion(false)
        } else {
          completion(true)
        }
      }
    } catch {
      print("Encoding error: \(error.localizedDescription)")
      completion(false)
    }
  }
  
  
  static func fetchPendingRequests(for userId: String, completion: @escaping ([Connection]) -> Void) {
    db.collection("connections")
      .whereField("toUserId", isEqualTo: userId)
      .whereField("status", isEqualTo: "pending")
      .getDocuments { snapshot, error in
        let connections = snapshot?.documents.compactMap { doc -> Connection? in
          let data = doc.data()
          guard let fromUserId = data["fromUserId"] as? String,
                let type = data["type"] as? String,
                let status = data["status"] as? String,
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
            return nil
          }
          
          return Connection(
            id: doc.documentID,
            fromUserId: fromUserId,
            toUserId: userId,
            type: type,
            status: status,
            timestamp: timestamp
          )
        } ?? []
        
        completion(connections)
      }
  }
}
