//
//  ConnectionCache.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-16.
//

import Foundation

final class ConnectionCache {
  static let shared = ConnectionCache()
  
  private init() {
    loadFromDisk()
  }
  
  private(set) var connections: [Connection] = []
  
  private let cachFilename = "connectionsCache.json"
  
  func updateConnections(_ newConnections: [Connection]) {
    LOGGER.debug("updateConnections is called with connections: \(newConnections)")
    connections = newConnections
    saveToDisk()
  }
  
  func clear() {
    connections.removeAll()
    saveToDisk()
  }
  
  func getFamily(for currentUserId: String) -> [User] {
    let family = getConnections(for: currentUserId, type: "Family")
    LOGGER.debug("getFamily is called: \(family)")
    return family
  }
  
  func getFriend(for currentUserId: String) -> [User] {
    getConnections(for: currentUserId, type: "Friend")
  }
  
  func getColleague(for currentUserId: String) -> [User] {
    getConnections(for: currentUserId, type: "Colleague")
  }
  
  func isConnected(with userId: String) -> Bool {
    return connections.contains { conn in
      (conn.fromUserId == userId || conn.toUserId == userId) && conn.status == "accepted"
    }
  }
  
  private func saveToDisk() {
    do {
      let data = try JSONEncoder().encode(connections)
      let url = getFileURL()
      try data.write(to: url, options: .atomic)
//      LOGGER.debug("Saved to disk with data: \(data) and url: \(url)")
    } catch {
      LOGGER.error("Error saving connections to disk: \(error)")
    }
  }
  
  private func loadFromDisk() {
    let url = getFileURL()
    do {
      let data = try Data(contentsOf: url)
      connections = try JSONDecoder().decode([Connection].self, from: data)
//      LOGGER.debug("Loaded from disk")
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
    LOGGER.debug("getconnections for user \(currentUserId): type \(type): connectionsCache: \(ConnectionCache.shared.connections): UserCace: \(UserCache.shared.users)")
    let users = ConnectionCache.shared.connections
      .filter { connection in
        return connection.status == "accepted"
        && connection.type.lowercased() == type.lowercased()
        && (connection.fromUserId == currentUserId || connection.toUserId == currentUserId)
      }
      .compactMap { connection in
        let otherUserId = (connection.fromUserId == currentUserId) ? connection.toUserId : connection.fromUserId
        LOGGER.debug("otherUserId: '\(otherUserId)'")
        return UserCache.shared.getUser(by: otherUserId)
      }
    
    
    LOGGER.debug("filtered users \(users)")
    return users
  }
}
