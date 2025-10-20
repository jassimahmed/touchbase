import SwiftUI

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
      let currentUID = LoginService.shared.getCurrentUID() ?? ""
      let otherUID = "bHRyshjwUTewIjApF9b5CVbDIAg2"
      let chatID = generateChatID(currentUID: currentUID, otherUID: otherUID)
      NavigationView()
        .previewDisplayName("TabView with ChatListView")
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
        
        Button(action: { isLogin.toggle() }) {
          Text(isLogin ? "Don’t have an account? Sign Up" :
                "Already have an account? Login")
          .foregroundColor(.blue)
        }
      }
      .padding()
      .onAppear {
        isSignedIn = LoginService.shared.isUserSignedIn()
      }
    }
  }
  
  private func generateChatID(currentUID: String, otherUID: String) -> String {
    [currentUID, otherUID].sorted().joined(separator: "_")
  }
  
  private func signUp() {
    guard !name.isEmpty, !username.isEmpty else {
      errorMessage = "Please enter name and username"
      return
    }
    
    LoginService.shared.signUp(name: name, username: username, email: email, password: password) { result in
      switch result {
      case .success:
        isSignedIn = true
      case .failure(let error):
        errorMessage = error.localizedDescription
      }
    }
  }
  
  private func signIn() {
    LoginService.shared.signIn(email: email, password: password) { result in
      switch result {
      case .success:
        isSignedIn = true
      case .failure(let error):
        errorMessage = error.localizedDescription
      }
    }
  }
  
  func signOut() {
    do {
      try LoginService.shared.signOut()
      isSignedIn = false
    } catch {
      print("Error signing out: \(error.localizedDescription)")
    }
  }
}
