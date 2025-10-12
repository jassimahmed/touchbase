import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Hashable {
    let id: String
    let name: String
    let username: String
}

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var users: [User] = []
    @State private var isLoading = false
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Searching users…")
                } else if users.isEmpty && !searchText.isEmpty {
                    Text("No users found")
                        .foregroundStyle(.secondary)
                } else {
                    List(users) { user in
                        HStack(spacing: 12) {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.username)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Search Users")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search by name or username")
            .onChange(of: searchText) { newValue in
                if !newValue.isEmpty {
                    searchUsers(query: newValue)
                } else {
                    users = [] // clear results when search is empty
                }
            }
        }
    }
    
    private func searchUsers(query: String) {
        isLoading = true
        let db = Firestore.firestore()
        
        // Firestore does not support OR queries easily, so we query by username or name separately
        let usersCollection = db.collection("users")
        
        // Query by username (prefix search)
        let usernameQuery = usersCollection
            .whereField("username", isGreaterThanOrEqualTo: query)
            .whereField("username", isLessThanOrEqualTo: query + "\u{f8ff}")
        
        // Query by name (prefix search)
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
            // Remove duplicates if a user matches both queries
            let uniqueUsers = Array(Set(results))
            self.users = uniqueUsers
            self.isLoading = false
        }
    }
}
