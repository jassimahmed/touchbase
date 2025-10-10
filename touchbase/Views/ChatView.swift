//
//  ChatView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-25.
//

import SwiftUI
import FirebaseAuth

struct ChatView: View {
  @StateObject private var chatService = ChatService()
  @State private var messageText = ""
  
  let chatID: String
  
  var body: some View {
    VStack {
      ScrollViewReader { scrollView in
        ScrollView {
          VStack(spacing: 8) {
            ForEach(chatService.messages) { message in
              HStack {
                if message.senderID == Auth.auth().currentUser?.uid {
                  Spacer()
                  Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                } else {
                  Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(10)
                  Spacer()
                }
              }
            }
          }
          .padding()
        }
        .onChange(of: chatService.messages.count) { _ in
          if let lastID = chatService.messages.last?.id {
            scrollView.scrollTo(lastID, anchor: .bottom)
          }
        }
      }
      
      HStack {
        TextField("Message", text: $messageText)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        
        Button("Send") {
          guard !messageText.isEmpty else { return }
          chatService.sendMessage(chatID: chatID, text: messageText)
          messageText = ""
        }
      }
      .padding()
    }
    .onAppear {
      chatService.observeMessages(chatID: chatID)
    }
  }
}
