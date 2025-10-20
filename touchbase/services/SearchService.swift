import Foundation
import FirebaseFirestore

struct SearchService {
  
  static func searchUsers(query: String, completion: @escaping ([User]) -> Void) {
    let db = Firestore.firestore()
    let usersCollection = db.collection("users")
    
    // Query by username
    let usernameQuery = usersCollection
      .whereField("username", isGreaterThanOrEqualTo: query)
      .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
    
    // Query by name
    let nameQuery = usersCollection
      .whereField("name", isGreaterThanOrEqualTo: query)
      .whereField("name", isLessThanOrEqualTo: query + "\u{f8ff}")
    
    var results: [User] = []
    let group = DispatchGroup()
    
    group.enter()
    usernameQuery.getDocuments { snapshot, error in
      defer { group.leave() }
      if let snapshot = snapshot {
        results.append(contentsOf: snapshot.documents.compactMap { doc in
          let data = doc.data()
          guard let name = data["name"] as? String,
                let username = data["username"] as? String else { return nil }
          return User(id: doc.documentID, name: name, username: username)
        })
      }
    }
    
    group.enter()
    nameQuery.getDocuments { snapshot, error in
      defer { group.leave() }
      if let snapshot = snapshot {
        results.append(contentsOf: snapshot.documents.compactMap { doc in
          let data = doc.data()
          guard let name = data["name"] as? String,
                let username = data["username"] as? String else { return nil }
          return User(id: doc.documentID, name: name, username: username)
        })
      }
    }
    
    group.notify(queue: .main) {
      // Remove duplicates if same user appears in both queries
      let uniqueUsers = Array(Set(results))
      completion(uniqueUsers)
    }
  }
}
