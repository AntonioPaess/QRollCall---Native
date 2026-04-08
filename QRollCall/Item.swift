//
//  Item.swift
//  QRollCall
//
//  Created by Antônio Paes on 08/04/26.
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
