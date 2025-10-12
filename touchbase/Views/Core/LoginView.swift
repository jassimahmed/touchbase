//
//  LoginView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-21.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
  @State private var email = ""
  @State private var password = ""
  @State private var name = ""
  @State private var username = ""
  @State private var isLogin = true
  @State private var errorMessage = ""
  @State private var isSignedIn = false
  
  var body: some View {
    if isSignedIn {
      // Navigate to ChatView
      let currentUID = Auth.auth().currentUser?.uid ?? ""
      let otherUID = "bHRyshjwUTewIjApF9b5CVbDIAg2"
      let chatID = generateChatID(currentUID: currentUID, otherUID: otherUID)
      NavigationView()
        .previewDisplayName("TabView with ChatListView")
//      ChatView(chatID: chatID)
    } else {
      VStack(spacing: 16) {
        Text(isLogin ? "Login" : "Sign Up")
          .font(.largeTitle).bold()
        
        if !isLogin {
          TextField("Full Name", text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
          
          TextField("Username", text: $username)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
        }
        
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
      .onAppear {
        if Auth.auth().currentUser != nil {
          isSignedIn = true
        }
      }
    }
  }
  
  private func generateChatID(currentUID: String, otherUID: String) -> String {
    return [currentUID, otherUID].sorted().joined(separator: "_")
  }
  
  private func signUp() {
    guard !name.isEmpty, !username.isEmpty else {
      errorMessage = "Please enter name and username"
      return
    }
    
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
      if let error = error {
        errorMessage = error.localizedDescription
        return
      }
      
      guard let uid = result?.user.uid else {
        errorMessage = "Unable to get user ID"
        return
      }
      
      // Create Firestore user document
      let db = Firestore.firestore()
      let userData: [String: Any] = [
        "uid": uid,
        "name": name,
        "username": username,
        "email": email,
        "createdAt": Timestamp()
      ]
      
      db.collection("users").document(uid).setData(userData) { error in
        if let error = error {
          errorMessage = "Failed to save user data: \(error.localizedDescription)"
        } else {
          isSignedIn = true
        }
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
  
  func signOut() {
    do {
      try Auth.auth().signOut()
      isSignedIn = false
    } catch {
      print("Error signing out: \(error.localizedDescription)")
    }
  }
}
