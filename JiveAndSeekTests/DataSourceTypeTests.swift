//
//  DataSourceTypeTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-03.
//

@testable import JiveAndSeek
import XCTest

class DataSourceTypeTests: XCTestCase {

    private var dataSource: DataSourceMock!

    override func setUpWithError() throws {
        dataSource = DataSourceMock()
    }

    override func tearDownWithError() throws {
        dataSource = nil
    }

    func testCreation() throws {
        // Act
        let d = DataSourceMock()

        // Assert
        XCTAssertNotNil(d)
    }

    func testNumberOfSections() throws {
        // Act
        let numberOfSections = dataSource.numberOfSections

        // Assert
        XCTAssertEqual(numberOfSections, 1)
    }

    func testNumberOfItems() throws {
        // Act
        let numberOfItems = dataSource.numberOfItems

        // Assert
        XCTAssertEqual(numberOfItems, 2)
    }

    func testItemsAtSection() throws {
        // Act
        let items = dataSource.items(at: 0)

        // Assert
        XCTAssertEqual(items?.count, 2)
        XCTAssertEqual(items, dataSource.rows)
    }

    func testItemAtIndexPath() throws {
        // Act
        let item = dataSource.item(at: IndexPath(row: 0, section: 0))

        // Assert
        XCTAssertEqual(item, dataSource.rows[0])
    }

    func testIndexPathForItem() throws {
        // Arrange
        let row = dataSource.rows[1]

        // Act
        let indexPath = dataSource.indexPath(for: row)

        // Assert
        let correct = IndexPath(row: 1, section: 0)
        XCTAssertEqual(indexPath, correct)
    }

    func testIndexPathForItemNotFound() throws {
        // Arrange
        let row = ContactRowMock(name: "Noe Viviana", email: "nv@me.ca")

        // Act
        let indexPath = dataSource.indexPath(for: row)

        // Assert
        XCTAssertNil(indexPath)
    }

}

private struct ContactRowMock: Equatable {
    let name: String
    let email: String
}

private class DataSourceMock: DataSourceType {

    typealias Item = ContactRowMock

    let rows = [ContactRowMock(name: "Marie", email: "m@me.fr"), ContactRowMock(name: "Bernardo", email: "b@me.com.br")]

    func items(at section: Int) -> [ContactRowMock]? {
        return rows
    }

}
