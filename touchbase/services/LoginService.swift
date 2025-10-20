//
//  LoginService.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-16.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import os

final class LoginService {
  static let shared = LoginService()
  private init() {}
  
  private let db = Firestore.firestore()
  
  /// Sign up a new user
  func signUp(name: String, username: String, email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let uid = result?.user.uid else {
        completion(.failure(NSError(domain: "LoginService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to get user ID"])))
        return
      }
      
      let userData: [String: Any] = [
        "uid": uid,
        "name": name,
        "username": username,
        "email": email,
        "createdAt": Timestamp()
      ]
      
      self.db.collection("users").document(uid).setData(userData) { error in
        if let error = error {
          completion(.failure(error))
        } else {
          completion(.success(()))
          self.loadUserConnectionsAfterLogin()
        }
      }
    }
  }
  
  /// Sign in existing user
  func signIn(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { _, error in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(()))
        self.loadUserConnectionsAfterLogin()
      }
    }
  }
  
  /// Sign out current user
  func signOut() throws {
    try Auth.auth().signOut()
  }
  
  /// Check if user is already signed in
  func isUserSignedIn() -> Bool {
    return Auth.auth().currentUser != nil
  }
  
  /// Get current user's UID
  func getCurrentUID() -> String? {
    return Auth.auth().currentUser?.uid
  }
  
  func loadUserConnectionsAfterLogin() {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    UserConnectionService.fetchUserConnections(for: uid) { result in
      switch result {
      case .success(let connections):
        print("✅ Loaded \(connections.count) connections for user \(uid)")
      case .failure(let error):
        print("⚠️ Failed to load connections: \(error.localizedDescription)")
      }
    }
  }
}
