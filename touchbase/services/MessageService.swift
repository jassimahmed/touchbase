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

class MessageService: ObservableObject {
  
  @Published var messages: [Message] = []
  private var db = Firestore.firestore()
  private var listener: ListenerRegistration?
  
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
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    
    let messageData: [String: Any] = [
      "senderID": currentUserID,
      "text": text,
      "timestamp": Timestamp(date: Date())
    ]
    
    let messagesRef = db.collection("chats").document(chatID).collection("messages")
    let chatRef = db.collection("chats").document(chatID)
    
    // Add the message
    messagesRef.addDocument(data: messageData) { error in
      if let error = error {
        print("Error sending message: \(error)")
        return
      }
      
      // Update lastMessage and timestamp on the chat document
      chatRef.updateData([
        "lastMessage": text,
        "timestamp": Timestamp(date: Date())
      ]) { error in
        if let error = error {
          print("Error updating chat metadata: \(error)")
        }
      }
    }
  }
  
  
  deinit {
    listener?.remove()
  }
}
