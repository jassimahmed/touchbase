//
//  ConnectionCache.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-16.
//

import Foundation
import Combine

final class ConnectionCache: ObservableObject {
  static let shared = ConnectionCache()
  
  private init() {
    loadFromDisk()
  }
  
  @Published private(set) var connections: [Connection] = []
  
  private let cachFilename = "connectionsCache.json"
  
  func updateConnections(_ newConnections: [Connection]) {
    let allConnections = Set(connections).union(newConnections)
    connections = Array(allConnections)
    saveToDisk()
  }
  
  func acceptConnection(withId id: String) {
    guard let index = connections.firstIndex(where: { $0.id == id }) else {
      // todo - throw excpeiont here
      return
    }
    connections[index].status = "accepted"
    saveToDisk()
  }
  
  func deleteConnection(withId id: String) {
      guard let index = connections.firstIndex(where: { $0.id == id }) else {
          // TODO: throw an exception or handle error if needed
          return
      }
      connections.remove(at: index)
      saveToDisk()
  }
  
  func clear() {
    connections.removeAll()
    saveToDisk()
  }
  
  func isConnected(with userId: String) -> Bool {
    return connections.contains { conn in
      (conn.fromUserId == userId || conn.toUserId == userId) && conn.status == "accepted"
    }
  }
  
  func getFamily(for currentUserId: String) -> [User] {
    return getConnections(for: currentUserId, type: "Family")
  }
  
  func getFriend(for currentUserId: String) -> [User] {
    getConnections(for: currentUserId, type: "Friend")
  }
  
  func getColleague(for currentUserId: String) -> [User] {
    getConnections(for: currentUserId, type: "Colleague")
  }
  
  private func saveToDisk() {
    do {
      let data = try JSONEncoder().encode(connections)
      let url = getFileURL()
      try data.write(to: url, options: .atomic)
    } catch {
      LOGGER.error("Error saving connections to disk: \(error)")
    }
  }
  
  private func loadFromDisk() {
    let url = getFileURL()
    do {
      let data = try Data(contentsOf: url)
      connections = try JSONDecoder().decode([Connection].self, from: data)
    } catch {
      LOGGER.error("Error loading connections from disk: \(error)")
      connections = []
    }
  }
  
  private func getFileURL() -> URL {
    let docs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    return docs.appendingPathComponent(cachFilename)
  }
  
  private func getConnections(for currentUserId: String, type: String) -> [User] {
    LOGGER.info("getconnections for user \(currentUserId): type \(type): connectionsCache: \(ConnectionCache.shared.connections): UserCace: \(UserCache.shared.users)")
    let users = ConnectionCache.shared.connections
      .filter { connection in
        return connection.status == "accepted"
        && connection.type.lowercased() == type.lowercased()
        && (connection.fromUserId == currentUserId || connection.toUserId == currentUserId)
      }
      .compactMap { connection in
        let otherUserId = (connection.fromUserId == currentUserId) ? connection.toUserId : connection.fromUserId
        LOGGER.info("getConnections otherUserId: '\(otherUserId)'")
        return UserCache.shared.getUser(by: otherUserId)
      }
    
    LOGGER.info("getConnections filtered users \(users)")
    return users
  }
}
