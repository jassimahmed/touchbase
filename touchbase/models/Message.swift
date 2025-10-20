//
//  Message.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-25.
//

import Foundation

struct Message: Identifiable {
    let id = UUID()          // Unique identifier for SwiftUI
    let senderID: String     // UID of the sender
    let text: String         // Message text
    let timestamp: Date      // When message was sent
}
