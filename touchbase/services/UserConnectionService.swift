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
      let ref = try db.collection("connections").addDocument(from: connection) { error in
        guard error == nil else {
          print("❌ Firestore error: \(error!.localizedDescription)")
          return completion(false)
        }
      }
      var updatedConnection = connection
      updatedConnection.id = ref.documentID
      ConnectionCache.shared.updateConnections([updatedConnection])
      completion(true)
    } catch {
      print("❌ Encoding error: \(error.localizedDescription)")
      completion(false)
    }
  }
  
  
  static func fetchPendingRequests(for userId: String, completion: @escaping ([Connection]) -> Void) {
    db.collection("connections")
      .whereField("toUserId", isEqualTo: userId)
      .whereField("status", isEqualTo: "pending")
      .getDocuments { snapshot, error in
        let connections = snapshot?.documents.compactMap {
          mapDocumentToConnection($0)
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
        
        let connections = snapshot?.documents.compactMap {
          mapDocumentToConnection($0)
        } ?? []
        
        ConnectionCache.shared.updateConnections(connections)
        
        cacheAcceptedConnectionUsersAsync(from: connections)
        
        completion(.success(connections))
      }
  }
  
  static func acceptConnectionRequest(connection: Connection, completion: @escaping (Bool) -> Void) {
    guard let connectionId = connection.id else {
      completion(false)
      return
    }
    
    db.collection("connections").document(connectionId)
      .updateData(["status": "accepted"]) { error in
        if error != nil {
          completion(false)
          return
        }
        ConnectionCache.shared.acceptConnection(withId: connectionId)
        
        var acceptedConnection = connection
        acceptedConnection.status = "accepted"
        cacheAcceptedConnectionUsersAsync(from: [acceptedConnection])
        completion(true)
      }
  }
  
  static func deleteConnectionRequest(connection: Connection, completion: @escaping (Bool) -> Void) {
    guard let connectionId = connection.id else {
      completion(false)
      return
    }
    
    db.collection("connections").document(connectionId).delete { error in
      if error != nil {
        completion(false)
        return
      }
      ConnectionCache.shared.deleteConnection(withId: connectionId)
      completion(true)
    }
  }
  
  private static func mapDocumentToConnection(_ doc: DocumentSnapshot) -> Connection? {
    guard let data = doc.data(),
          let fromUserId = data["fromUserId"] as? String,
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
  }
  
  private static func cacheAcceptedConnectionUsersAsync(from connections: [Connection]) {
    DispatchQueue.global(qos: .background).async {
      cacheAcceptedConnectionUsers(from: connections)
    }
  }
  
  private static func cacheAcceptedConnectionUsers(from connections: [Connection]) {
    let acceptedUserIds = connections
      .filter { $0.status == "accepted" }
      .flatMap { [$0.fromUserId, $0.toUserId] }
      .unique()
    
    guard !acceptedUserIds.isEmpty else { return }
    
    let group = DispatchGroup()
    var fetchedUsers: [User] = []
    
    let chunks = acceptedUserIds.chunked(into: 10)
    
    for chunk in chunks {
      group.enter()
      db.collection("users")
        .whereField(FieldPath.documentID(), in: chunk)
        .getDocuments { snapshot, error in
          defer { group.leave() }
        
          if error != nil {
            return
          }
          
          let users = snapshot?.documents.compactMap { doc -> User? in
            let data = doc.data()
            guard let name = data["name"] as? String,
                  let username = data["username"] as? String else { return nil }
            return User(id: doc.documentID, name: name, username: username)
          } ?? []
          
          fetchedUsers.append(contentsOf: users)
        }
    }
    
    group.notify(queue: .global(qos: .background)) {
      if !fetchedUsers.isEmpty {
        UserCache.shared.updateUsers(fetchedUsers)
      }
    }
  }
  
}

private extension Array where Element: Hashable {
  func unique() -> [Element] {
    var seen = Set<Element>()
    return filter { seen.insert($0).inserted }
  }
}

private extension Array {
  func chunked(into size: Int) -> [[Element]] {
    stride(from: 0, to: count, by: size).map {
      Array(self[$0 ..< Swift.min($0 + size, count)])
    }
  }
}
