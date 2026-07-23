//
//  Item.swift
//  OpnsenseWidget
//
//  Created by Iain Lennox on 23/07/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
