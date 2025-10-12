import Foundation
import FirebaseAuth
import FirebaseFirestore

struct AuthService {
  
  static func getCurrentUser(completion: @escaping (User?) -> Void) {
    guard let currentUser = Auth.auth().currentUser else {
      completion(nil)
      return
    }
    
    let db = Firestore.firestore()
    let userRef = db.collection("users").document(currentUser.uid)
    
    userRef.getDocument { snapshot, error in
      if let data = snapshot?.data(),
         let name = data["name"] as? String,
         let username = data["username"] as? String {
        let user = User(id: currentUser.uid, name: name, username: username)
        completion(user)
      } else {
        completion(nil)
      }
    }
  }
}
