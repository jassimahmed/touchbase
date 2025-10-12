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
              NavigationLink(destination: ProfileView(user: user, isCurrentUser: false)) {
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
    
    SearchService.searchUsers(query: query) { users in
      self.users = users
      self.isLoading = false
    }
  }
}
