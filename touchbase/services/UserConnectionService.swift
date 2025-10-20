//
//  ConnectionService.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-12.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import os

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
  
  static func fetchUserConnections(for userId: String, completion: @escaping (Result<[Connection], Error>) -> Void) {
    
    db.collection("connections")
      .whereFilter(
        Filter.orFilter([
          Filter.whereField("fromUserId", isEqualTo: userId),
          Filter.whereField("toUserId", isEqualTo: userId)
        ])
      )
      .getDocuments { snapshot, error in
        if let error = error {
          completion(.failure(error))
          return
        }
        
        let connections = snapshot?.documents.compactMap { doc -> Connection? in
          let data = doc.data()
          guard let fromUserId = data["fromUserId"] as? String,
                let toUserId = data["toUserId"] as? String,
                let type = data["type"] as? String,
                let status = data["status"] as? String,
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() else {
            return nil
          }
          return Connection(
            id: doc.documentID,
            fromUserId: fromUserId,
            toUserId: toUserId,
            type: type,
            status: status,
            timestamp: timestamp
          )
        } ?? []
        
        LOGGER.debug("fetchUserConnections(): connections: \(connections)")
        
        ConnectionCache.shared.updateConnections(connections)
        
        LOGGER.debug("ConnectionCache array \(ConnectionCache.shared.connections)")
        completion(.success(connections))
      }
  }
  
  static func acceptConnectionRequest(fromUserId: String, completion: @escaping (Bool) -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
      completion(false)
      return
    }
    
    db.collection("connections")
      .whereField("fromUserId", isEqualTo: fromUserId)
      .whereField("toUserId", isEqualTo: currentUserId)
      .whereField("status", isEqualTo: "pending")
      .getDocuments { snapshot, error in
        if let error = error {
          print("Error finding connection request: \(error.localizedDescription)")
          completion(false)
          return
        }
        
        guard let doc = snapshot?.documents.first else {
          print("No pending connection request found.")
          completion(false)
          return
        }
        
        // Update the status to "accepted"
        db.collection("connections").document(doc.documentID)
          .updateData(["status": "accepted"]) { error in
            if let error = error {
              print("Error updating connection status: \(error.localizedDescription)")
              completion(false)
            } else {
              // Update cache immediately
              var updatedConnections = ConnectionCache.shared.connections
              if let index = updatedConnections.firstIndex(where: { $0.id == doc.documentID }) {
                updatedConnections[index].status = "accepted"
              } else {
                // If it wasn’t in cache, add it freshly
                let data = doc.data()
                if let type = data["type"] as? String,
                   let type = data["type"] as? String,
                   let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() {
                  let newConn = Connection(
                    id: doc.documentID,
                    fromUserId: fromUserId,
                    toUserId: currentUserId,
                    type: type,
                    status: "accepted",
                    timestamp: timestamp
                  )
                  updatedConnections.append(newConn)
                }
              }
              ConnectionCache.shared.updateConnections(updatedConnections)
              completion(true)
            }
          }
      }
  }
  
  static func deleteConnectionRequest(fromUserId: String, completion: @escaping (Bool) -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
      completion(false)
      return
    }
    
    db.collection("connections")
      .whereField("fromUserId", isEqualTo: fromUserId)
      .whereField("toUserId", isEqualTo: currentUserId)
      .whereField("status", isEqualTo: "pending")
      .getDocuments { snapshot, error in
        if let error = error {
          print("Error finding connection request to delete: \(error.localizedDescription)")
          completion(false)
          return
        }
        
        guard let doc = snapshot?.documents.first else {
          print("No pending connection request found to delete.")
          completion(false)
          return
        }
        
        deleteDoc(doc, completion: completion)
      }
  }
  
  static func deleteDoc(_ doc: QueryDocumentSnapshot, completion: @escaping (Bool) -> Void) {
    // Delete the Firestore document
    db.collection("connections").document(doc.documentID).delete { error in
      if let error = error {
        print("Error deleting connection request: \(error.localizedDescription)")
        completion(false)
      } else {
        // Update local cache
        let updatedConnections = ConnectionCache.shared.connections.filter {
          $0.id != doc.documentID
        }
        ConnectionCache.shared.updateConnections(updatedConnections)
        
        completion(true)
      }
    }
  }
  
}
