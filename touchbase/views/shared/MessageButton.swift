//
//  MessageButton.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-27.
//

import SwiftUI

struct MessageButton: View {
    let user: User
    var onMessageTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onMessageTap?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "bubble.left.and.bubble.right.fill")
                    .font(.caption)
                Text("Message")
                    .font(.subheadline.bold())
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.blue.opacity(0.8))
            .foregroundStyle(.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }
}
