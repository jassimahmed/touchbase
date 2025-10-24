//
//  ConnectionListView.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-23.
//

import SwiftUI

struct ConnectionListView: View {
  let users: [User]
  
  var body: some View {
    if users.isEmpty {
      Text("No connections yet.")
        .foregroundStyle(.secondary)
        .padding()
    } else {
      List(users, id: \.id) { user in
        VStack(alignment: .leading, spacing: 2) {
          Text(user.name)
            .font(.body)
          Text("@\(user.username)")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
      }
      .listStyle(.plain)
    }
  }
}
