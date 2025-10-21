//
//  User.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-12.
//

struct User: Identifiable, Hashable, Codable {
  let id: String
  let name: String
  let username: String
  
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  static func == (lhs: User, rhs: User) -> Bool {
    lhs.id == rhs.id
  }
}
