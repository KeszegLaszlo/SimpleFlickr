//
//  CompositionalLayout.swift
//  UserInterface
//
//  Created by Keszeg László on 2025. 08. 09.
//

import SwiftUI

// MARK: - Constants
private enum Constants {
    enum Layout {
        static let defaultRowHeight: CGFloat = 200
        static let singleItemRowHeight: CGFloat = 200
        static let multiItemRowHeight: CGFloat = 100
        static let fourItemRowHeight: CGFloat = 300
        static let lastRowHeight: CGFloat = 230
        static let columnWidthFactor: CGFloat = 0.33
    }
}

public struct CompositionalLayout<Content: View>: View {
    private var count: Int = 3
    private var spacing: CGFloat = 6

    private var content: Content

    // MARK: - Row kind
    private enum Row: Int { case one = 0, two, three, four }

    // MARK: - Body
    public var body: some View {
        Group(subviews: content) { collection in
            let chunked = collection.chunked(count)

            ForEach(chunked) {
                switch Row(rawValue: $0.layoutID) ?? .four {
                case .one:    layout1($0.collection)
                case .two:    layout2($0.collection)
                case .three:  layout3($0.collection)
                case .four:   layout4($0.collection)
                }
            }
        }
    }

    public init(
        count: Int = 3,
        spacing: CGFloat = 6,
        @ViewBuilder content: () -> Content
    ) {
        self.count = count
        self.spacing = spacing
        self.content = content()
    }

    // MARK: - Layout builders
    @ViewBuilder
    private func layout1(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader {
            let width = $0.size.width - spacing

            HStack(spacing: spacing) {
                if let first = collection.first {
                    first
                }

                if collection.count != 1 {
                    VStack(spacing: spacing) {
                        ForEach(collection.dropFirst()) {
                            $0.frame(width: width * Constants.Layout.columnWidthFactor)
                        }
                    }
                }
            }
        }
        .frame(height: Constants.Layout.defaultRowHeight)
    }

    @ViewBuilder
    private func layout2(_ collection: [SubviewsCollection.Element]) -> some View {
        HStack(spacing: spacing) {
            ForEach(collection) { $0 }
        }
        .frame(
            height: collection.count == 1 ? Constants.Layout.singleItemRowHeight : Constants.Layout.multiItemRowHeight
        )
    }

    @ViewBuilder
    private func layout3(_ collection: [SubviewsCollection.Element]) -> some View {
        GeometryReader {
            let width = $0.size.width - spacing

            HStack(spacing: spacing) {
                if collection.count == 4 {
                    VStack(spacing: spacing) {
                        ForEach(collection.prefix(2)) { $0 }
                    }
                    VStack(spacing: spacing) {
                        ForEach(collection.dropFirst(2)) { $0 }
                    }
                } else {
                    if let first = collection.first {
                        first
                            .frame(width: collection.count == 1 ? nil : width * Constants.Layout.columnWidthFactor)
                    }

                    if collection.count != 1 {
                        VStack(spacing: spacing) {
                            ForEach(collection.dropFirst()) { $0 }
                        }
                    }
                }
            }
        }
        .frame(height: collection.count == 4 ? Constants.Layout.fourItemRowHeight : Constants.Layout.defaultRowHeight)
    }

    @ViewBuilder
    private func layout4(_ collection: [SubviewsCollection.Element]) -> some View {
        HStack(spacing: spacing) {
            ForEach(collection) { $0 }
        }
        .frame(height: Constants.Layout.lastRowHeight)
    }
}

fileprivate extension SubviewsCollection {
    func chunked(_ size: Int) -> [ChunkedCollection] {
        stride(from: .zero, to: count, by: size).map {
            let collection = Array(self[$0..<Swift.min($0 + size, count)])
            let layoutID = ($0/size) % 4
            return .init(layoutID: layoutID, collection: collection)
        }
    }

    struct ChunkedCollection: Identifiable {
        var id: UUID = .init()
        var layoutID: Int
        var collection: [SubviewsCollection.Element]
    }
}

#Preview {
    @Previewable @State var count = 3

    ScrollView(.vertical) {
        LazyVStack(spacing: 6) {
            Picker("", selection: $count) {
                ForEach(1...4, id: \.self) {
                    Text("Count = \($0)")
                        .tag($0)
                }
            }
            .pickerStyle(.segmented)

            CompositionalLayout(count: count) {
                ForEach(0...20, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.9).gradient)
                }
            }
            .animation(.bouncy, value: count)
        }
        .padding(15)
    }
}
