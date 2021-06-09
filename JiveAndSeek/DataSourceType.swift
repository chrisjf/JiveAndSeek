//
//  DataSourceType.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-03.
//

import Foundation

public protocol DataSourceType {

    associatedtype Item

    func items(at section: Int) -> [Item]?
    func item(at indexPath: IndexPath) -> Item?
    func indexPath(for item: Item) -> IndexPath?

}

// MARK: Number of Sections and Items

public extension DataSourceType {

    var numberOfSections: Int {
        return 1
    }

    var numberOfItems: Int {
        var numberOfItems = 0
        for section in 0 ..< numberOfSections {
            numberOfItems += items(at: section)?.count ?? 0
        }
        return numberOfItems
    }

}

// MARK: Item and IndexPath

public extension DataSourceType where Item: Equatable {

    func item(at indexPath: IndexPath) -> Item? {
        let items = items(at: indexPath.section)
        return items?[indexPath.row]
    }

    func indexPath(for item: Item) -> IndexPath? {
        var indexPath: IndexPath?
        for section in 0 ..< numberOfSections {
            if let items = items(at: section),
               let rowIndex = items.firstIndex(of: item) {
                indexPath = IndexPath(item: rowIndex, section: section)
                break
            }
        }
        return indexPath
    }

}
