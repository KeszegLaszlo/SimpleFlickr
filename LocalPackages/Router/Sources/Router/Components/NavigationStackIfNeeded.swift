//
//  NavigationStackIfNeeded.swift
//  Router
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

struct NavigationStackIfNeeded<Content: View>: View {

    @Binding var path: [AnyDestination]
    var addNavigationView: Bool = true
    @ViewBuilder var content: Content

    var body: some View {
        if addNavigationView {
            NavigationStack(path: $path) {
                content
                    .navigationDestination(for: AnyDestination.self) { value in
                        value.destination
                    }
            }
            .accentColor(.indigo)
        } else {
            content
        }
    }
}
