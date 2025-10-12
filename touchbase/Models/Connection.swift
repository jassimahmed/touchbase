//
//  Message.swift
//  touchbase
//
//  Created by Jassim Ahmed on 2025-09-25.
//

import Foundation
import FirebaseFirestore

struct Connection: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let fromUserId: String
    let toUserId: String
    let type: String
    let status: String
    let timestamp: Date
}
