//
//  String+Extensions.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

extension String {
    var stableHashValue: Int {
        let unicodeScalars = self.unicodeScalars.map { $0.value }
        return unicodeScalars.reduce(5381) { ($0 << 5) &+ $0 &+ Int($1) }
    }
}
