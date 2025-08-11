//
//  File.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 10.
//

import SwiftUI

public struct GlobalConstants {
    public enum Size {
        public static let cornerRadius: CGFloat = 15
        public static let bodyPadding: CGFloat = 15
        public static let blurRadius: CGFloat = 10
    }

    public enum Shadow {
        public static let color: Color = .black.opacity(0.18)
        public static let radius: CGFloat = 10
        public static let shadowX: CGFloat = 0
        public static let shadowY: CGFloat = 6
    }
}
