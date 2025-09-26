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
  
  var body: some View {
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
  
  private func signUp() {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
      if let error = error {
        errorMessage = error.localizedDescription
      } else {
        errorMessage = "✅ Signed up successfully"
      }
    }
  }
  
  private func signIn() {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
      if let error = error {
        errorMessage = error.localizedDescription
      } else {
        errorMessage = "✅ Logged in successfully"
      }
    }
  }
}
