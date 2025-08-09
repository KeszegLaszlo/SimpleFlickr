//
//  String+Extensions.swift
//  Logger
//
//  Created by Keszeg László on 2025. 08. 09.
//

import Foundation

extension String {
    func clipped(maxCharacters: Int) -> String {
        String(prefix(maxCharacters))
    }
    
    func replaceSpacesWithUnderscores() -> String {
        self.replacingOccurrences(of: " ", with: "_")
    }
    
    func clean(maxCharacters: Int) -> String {
        self
            .clipped(maxCharacters: 40)
            .replaceSpacesWithUnderscores()
    }
}
