//
//  Message.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-25.
//

import Foundation
import FirebaseFirestore

struct Connection: Identifiable, Hashable, Codable {
    var id: String? // Firestore document ID
    let fromUserId: String
    let toUserId: String
    var type: String
    var status: String
    var timestamp: Date
}
