//
//  UserCache.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-20.
//

import Foundation

final class UserCache {
  static let shared = UserCache()
  
  private init() {
    loadFromDisk()
  }
  
  private(set) var users: [User] = []
  
  private let fileName = "usersCache.json"

  func updateUsers(_ newUsers: [User]) {
    let allUsers = Set(users).union(newUsers)
    users = Array(allUsers)
    saveToDisk()
  }
  
  func addOrUpdateUser(_ user: User) {
    if let index = users.firstIndex(where: { $0.id == user.id }) {
      users[index] = user
    } else {
      users.append(user)
    }
    saveToDisk()
  }
  
  func clear() {
    users.removeAll()
    saveToDisk()
  }
  
  func getUser(by id: String) -> User? {
    return users.first(where: { $0.id == id })
  }
  
  func containsUser(with id: String) -> Bool {
    return users.contains(where: { $0.id == id })
  }
  
  private func getFileURL() -> URL {
    let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    return cacheDir.appendingPathComponent(fileName)
  }
  
  private func saveToDisk() {
    do {
      let data = try JSONEncoder().encode(users)
      let url = getFileURL()
      try data.write(to: url, options: .atomic)
    } catch {
      LOGGER.error("Error saving users to disk: \(error)")
    }
  }
  
  private func loadFromDisk() {
    let url = getFileURL()
    do {
      let data = try Data(contentsOf: url)
      users = try JSONDecoder().decode([User].self, from: data)
    } catch {
      users = []
      LOGGER.error("Error loading users from disk: \(error)")
    }
  }
}
