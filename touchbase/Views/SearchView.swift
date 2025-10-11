//
//  SearchView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-10.
//

import SwiftUI

struct User: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let username: String
}

struct SearchView: View {
    // Sample data
    let users = [
        User(name: "John Doe", username: "@johndoe"),
        User(name: "Jane Smith", username: "@janesmith"),
        User(name: "Alice Lee", username: "@alicelee"),
        User(name: "Bob Johnson", username: "@bobjohnson")
    ]
    
    @State private var searchText: String = ""
    
    // Filtered users based on search
    var filteredUsers: [User] {
        if searchText.isEmpty { return users }
        return users.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.username.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredUsers) { user in
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
            .navigationTitle("Search Users")
            .searchable(text: $searchText, placement: .automatic, prompt: "Search by name or username")
        }
    }
}

#Preview {
    SearchView()
        .previewLayout(.sizeThatFits)
}
