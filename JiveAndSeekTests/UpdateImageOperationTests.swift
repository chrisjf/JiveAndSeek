//
//  UpdateImageOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-08.
//

@testable import JiveAndSeek
import XCTest

class UpdateImageOperationTests: XCTestCase {

    private let albumPierreLapointe = Album(name: "Paris Tristesse",
                                            artwork: nil,
                                            artworkUrl: "https://pierrelapointe.com/albums/paris-tristesse/",
                                            releaseDate: Date(timeIntervalSince1970: 1423555200),
                                            genre: "Musique francophone",
                                            price: Decimal(9.99),
                                            currency: "CAD",
                                            copyright: "℗ 2014 Les Disques Audiogramme inc.")

    let albumJorgeBen = Album(name: "A Tábua de Esmeralda",
                              artwork: nil,
                              artworkUrl: "http://jorgebenjor.com.br/",
                              releaseDate: Date(timeIntervalSince1970: 126259200),
                              genre: "MPB",
                              price: Decimal(9.99),
                              currency: "CAD",
                              copyright: "℗ 1974 Universal Music Ltda")

    func testCreation() throws {
        // Arrange
        let ds = TableViewDataSource()

        // Act
        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds)

        // Assert
        XCTAssertNotNil(op)
    }

    func testExecute() throws {
        // Arrange
        let ds = TableViewDataSource()
        ds.rows = [albumJorgeBen, albumPierreLapointe]

        let tableView = TableViewMock()
        ds.tableView = tableView

        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds, dispatchQueue: DispatchQueueMock())

        let image = UIImage(systemName: "pianokeys")
        op.image = image

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(ds.rows[1].artwork, image)
        XCTAssertTrue(tableView.reloadWasCalled)
        let indexPath = IndexPath(row: 1, section: 0)
        XCTAssertEqual(tableView.indexPaths, [indexPath])
        XCTAssertEqual(tableView.animation, UITableView.RowAnimation.none)
    }

    func testExecuteIsCancelled() throws {
        // Arrange
        let ds = TableViewDataSource()
        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds)
        op.cancel()

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteNoImage() throws {
        // Arrange
        let ds = TableViewDataSource()
        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds)
        op.image = nil

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteNoDataSource() throws {
        // Arrange
        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: nil)

        let image = UIImage(systemName: "pianokeys")
        op.image = image

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteIsCancelledDuringDispatchQueue() throws {
        // Arrange
        let ds = TableViewDataSource()
        ds.rows = [albumJorgeBen, albumPierreLapointe]

        let tableView = TableViewMock()
        ds.tableView = tableView

        let queue = DispatchQueueMock()

        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds, dispatchQueue: queue)

        let image = UIImage(systemName: "pianokeys")
        op.image = image

        queue.preCompletion = {
            op.cancel()
        }

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
        XCTAssertFalse(tableView.reloadWasCalled)
    }

    func testExecuteRowNoLongerExists() throws {
        // Arrange
        let ds = TableViewDataSource()
        ds.rows = [albumJorgeBen, albumPierreLapointe]

        let tableView = TableViewMock()
        ds.tableView = tableView

        let queue = DispatchQueueMock()

        let op = UpdateImageOperation(album: albumPierreLapointe, dataSource: ds, dispatchQueue: queue)

        let image = UIImage(systemName: "pianokeys")
        op.image = image

        queue.preCompletion = {
            ds.rows = []
        }

        // Act
        op.execute()

        // Assert
        XCTAssertEqual(op.isFinished, true)
        XCTAssertFalse(tableView.reloadWasCalled)
    }

}

private class DispatchQueueMock: DispatchQueueProtocol {

    var preCompletion: (() -> Void)?

    func async(execute work: @escaping @convention(block) () -> Void) {
        if let cancelBlock = preCompletion {
            cancelBlock()
        }
        work()
    }

}

private class TableViewMock: UITableView {

    var reloadWasCalled = false
    var indexPaths: [IndexPath]!
    var animation: UITableView.RowAnimation!

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        reloadWasCalled = true
        self.indexPaths = indexPaths
        self.animation = animation
    }

}

private class TableViewDataSourceMock: TableViewDataSource {

    typealias Item = Album

    func indexPath(for item: Item) -> IndexPath? {
        return nil
    }

}
