//
//  AuthView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-21.
//

import SwiftUI
import FirebaseAuth

struct AuthView: View {
  @State private var email = ""
  @State private var password = ""
  @State private var isLogin = true
  @State private var errorMessage = ""
  @State private var isSignedIn = false
  
//  Auth.auth().addStateDidChangeListener, so the app automatically remembers if the user is already signed in when the app launches.
  
 
  
  var body: some View {
    if isSignedIn {
      // Navigate to ChatView
      let currentUID = "omsNcMGNr2RYbZkwJFVDLF2bheI2"
      let otherUID = "bHRyshjwUTewIjApF9b5CVbDIAg2"	
      let chatID = generateChatID(currentUID: currentUID, otherUID: otherUID)
      NavigationView()
          .previewDisplayName("TabView with ChatListView")
//      ChatView(chatID: chatID)
    } else {
      VStack(spacing: 16) {
        Text(isLogin ? "Login" : "Sign Up")
          .font(.largeTitle).bold()
        
        TextField("Email", text: $email)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .keyboardType(.emailAddress)
          .autocapitalization(.none)
        
        SecureField("Password", text: $password)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        
        if !errorMessage.isEmpty {
          Text(errorMessage)
            .foregroundColor(.red)
            .font(.caption)
        }
        
        Button(action: {
          if isLogin {
            signIn()
          } else {
            signUp()
          }
        }) {
          Text(isLogin ? "Login" : "Sign Up")
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        
        Button(action: {
          isLogin.toggle()
        }) {
          Text(isLogin ? "Don’t have an account? Sign Up" :
                "Already have an account? Login")
          .foregroundColor(.blue)
        }
      }
      .padding()
    }
  }
  
  private func generateChatID(currentUID: String, otherUID: String) -> String {
      return [currentUID, otherUID].sorted().joined(separator: "_")
  }
  
  private func signUp() {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
      if let error = error {
        errorMessage = error.localizedDescription
      } else {
        isSignedIn = true
      }
    }
  }
  
  private func signIn() {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      if let error = error {
        errorMessage = error.localizedDescription
      } else {
        isSignedIn = true
      }
    }
  }
}
