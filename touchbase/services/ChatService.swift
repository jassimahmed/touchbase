//
//  ChatListViewModel.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-28.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class ChatService: ObservableObject {
  @Published var chats: [Chat] = []
  @Published var participantNames: [String: String] = [:] // [userID: name]
  
  private var db = Firestore.firestore()
  private var listener: ListenerRegistration?
  
  init() {
    fetchChats()
  }
  
  func fetchChats() {
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    
    listener = db.collection("chats")
      .whereField("participants", arrayContains: currentUserID)
      .order(by: "timestamp", descending: true)
      .addSnapshotListener { snapshot, error in
        if let error = error {
          print("Error fetching chats: \(error)")
          return
        }
        
        self.chats = snapshot?.documents.compactMap { doc in
          let data = doc.data()
          let id = doc.documentID
          let participants = data["participants"] as? [String] ?? []
          let lastMessage = data["lastMessage"] as? String
          let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
          
          // Resolve participant names
          for participantID in participants where participantID != currentUserID {
            self.resolveUserName(userID: participantID)
          }
          
          return Chat(id: id, participants: participants, lastMessage: lastMessage, timestamp: timestamp)
        } ?? []
      }
  }
  
  func createOrFetchChat(with userId: String, completion: @escaping (String?) -> Void) {
    guard let currentUserId = Auth.auth().currentUser?.uid else {
      completion(nil)
      return
    }
    
    let chatsRef = db.collection("chats")
    
    chatsRef
      .whereField("participants", arrayContains: currentUserId)
      .getDocuments { snapshot, error in
        if let error = error {
          print("Error fetching chats: \(error)")
          completion(nil)
          return
        }
        
        // Find if chat already exists
        if let existingChat = snapshot?.documents.first(where: { doc in
          let participants = doc["participants"] as? [String] ?? []
          return participants.contains(userId)
        }) {
          completion(existingChat.documentID)
          return
        }
        
        // If no chat exists, create one
        let newChatRef = chatsRef.document()
        let chatData: [String: Any] = [
          "participants": [currentUserId, userId],
          "lastMessage": "",
          "timestamp": Timestamp(date: Date())
        ]
        
        newChatRef.setData(chatData) { error in
          if let error = error {
            print("Error creating chat: \(error)")
            completion(nil)
          } else {
            completion(newChatRef.documentID)
          }
        }
      }
  }
  
  private func resolveUserName(userID: String) {
    // Check cache first
    if let user = UserCache.shared.getUser(by: userID) {
      DispatchQueue.main.async {
        self.participantNames[userID] = user.name
      }
      return
    }
    
    // Fetch from Firestore if not in cache
    db.collection("users").document(userID).getDocument { doc, error in
      guard let doc = doc, doc.exists, let data = doc.data() else { return }
      let name = data["name"] as? String ?? "Unknown"
      let username = data["username"] as? String ?? ""
      
      let user = User(id: userID, name: name, username: username)
      UserCache.shared.addOrUpdateUser(user)
      
      DispatchQueue.main.async {
        self.participantNames[userID] = name
      }
    }
  }
  
  deinit {
    listener?.remove()
  }
}
