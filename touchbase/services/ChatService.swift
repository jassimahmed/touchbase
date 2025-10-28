//
//  ChatService.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-25.
//

import Firebase
import FirebaseFirestore
import SwiftUI
import Combine
import FirebaseAuth

class ChatService: ObservableObject {
  
  @Published var messages: [Message] = []
  private var db = Firestore.firestore()
  private var listener: ListenerRegistration?
  
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
  
  func observeMessages(chatID: String) {
    listener = db.collection("chats").document(chatID).collection("messages")
      .order(by: "timestamp", descending: false)
      .addSnapshotListener { snapshot, error in
        guard let documents = snapshot?.documents else { return }
        self.messages = documents.compactMap { doc in
          let data = doc.data()
          guard let senderID = data["senderID"] as? String,
                let text = data["text"] as? String,
                let timestamp = data["timestamp"] as? Timestamp else { return nil }
          return Message(senderID: senderID, text: text, timestamp: timestamp.dateValue())
        }
      }
  }
  
  func sendMessage(chatID: String, text: String) {
    guard let currentUserID = Auth.auth().currentUser?.uid else {
      return
    }
    
    let messageData: [String: Any] = [
      "senderID": currentUserID,
      "text": text,
      "timestamp": Timestamp(date: Date())
    ]
    
    db.collection("chats").document(chatID).collection("messages")
      .addDocument(data: messageData) { error in
        if let error = error {
          print("Error sending message: \(error)")
        }
      }
  }
  
  deinit {
    listener?.remove()
  }
}
