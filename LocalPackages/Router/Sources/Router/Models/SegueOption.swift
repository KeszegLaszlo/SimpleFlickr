//
//  SegueOption.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09.
//

public enum SegueOption {
    case push, sheet, fullScreenCover

    var shouldAddNewNavigationView: Bool {
        switch self {
        case .push: false
        case .sheet, .fullScreenCover: true
        }
    }
}
