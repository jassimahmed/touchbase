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
  
  private let userDefaultsKey = "connectionsCache"
  
  func updateConnections(_ newConnections: [Connection]) {
    connections = newConnections
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
  
  private func saveToDisk() {
    do {
      let data = try JSONEncoder().encode(connections)
      UserDefaults.standard.set(data, forKey: userDefaultsKey)
      UserDefaults.standard.synchronize()
    } catch {
      print("Error saving connections to disk: \(error)")
    }
  }
  
  private func loadFromDisk() {
    guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
      connections = []
      return
    }
    do {
      connections = try JSONDecoder().decode([Connection].self, from: data)
    } catch {
      print("Error loading connections from disk: \(error)")
      connections = []
    }
  }
}
