//
//  Chat.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-10-28.
//

import Foundation

struct Chat: Identifiable, Codable {
    var id: String
    var participants: [String]
    var lastMessage: String?
    var timestamp: Date
}
