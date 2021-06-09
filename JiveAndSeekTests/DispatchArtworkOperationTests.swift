//
//  DispatchArtworkOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-08.
//

@testable import JiveAndSeek
import XCTest

class DispatchArtworkOperationTests: XCTestCase {

    private var operation: DispatchArtworkOperation!
    private var queue: OperationQueue!

    override func setUpWithError() throws {
        queue = OperationQueue()
        queue.name = "DispatchArtworkOperationTestsQueue"
        queue.isSuspended = true

        operation = DispatchArtworkOperation(queue: queue, dataSource: nil)
    }

    override func tearDownWithError() throws {
        operation = nil
        queue = nil
    }

    func testCreation() throws {
        // Arrange
        let ds = TableViewDataSource()

        // Act
        let op = DispatchArtworkOperation(queue: queue, dataSource: ds)

        // Assert
        XCTAssertNotNil(op)
    }

    func testExecute() throws {
        // Arrange
        let pierreLapointe = Album(name: "Paris Tristesse",
                                   artwork: UIImage(systemName: "pianokeys"),
                                   artworkUrl: "https://pierrelapointe.com/albums/paris-tristesse/",
                                   releaseDate: Date(timeIntervalSince1970: 1423555200),
                                   genre: "Musique francophone",
                                   price: Decimal(9.99),
                                   currency: "CAD",
                                   copyright: "℗ 2014 Les Disques Audiogramme inc.")
        operation.albums = [pierreLapointe]

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(queue.operations.count, 3)
        let operations = queue.operations
        XCTAssertTrue(operations[0] is FetchArtworkOperation)
        XCTAssertTrue(operations[1] is BlockOperation)
        XCTAssertTrue(operations[2] is UpdateImageOperation)
        XCTAssertEqual(operation.isFinished, true)
    }

    func testExecuteIsCancelled() throws {
        // Arrange
        operation.cancel()

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(queue.operations.count, 0)
        XCTAssertEqual(operation.isCancelled, true)
        XCTAssertEqual(operation.isFinished, true)
    }

    func testExecuteNoAlbums() throws {
        // Arrange
        operation.albums = []

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(queue.operations.count, 0)
        XCTAssertEqual(operation.isFinished, true)
    }

}
