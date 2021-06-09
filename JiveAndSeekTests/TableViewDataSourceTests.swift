//
//  TableViewDataSourceTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-03.
//

@testable import JiveAndSeek

import XCTest

class TableViewDataSourceTests: XCTestCase {

    private var dataSource: TableViewDataSource!

    private let jorgeBen = Album(name: "A Tábua de Esmeralda",
                                 artwork: UIImage(systemName: "music.note")!,
                                 artworkUrl: "http://jorgebenjor.com.br/",
                                 releaseDate: Date(timeIntervalSince1970: 126259200),
                                 genre: "MPB",
                                 price: Decimal(9.99),
                                 currency: "CAD",
                                 copyright: "℗ 1974 Universal Music Ltda")

    override func setUpWithError() throws {
        dataSource = TableViewDataSource()
    }

    override func tearDownWithError() throws {
        dataSource = nil
    }

    func testCreation() throws {
        // Act
        let ds = TableViewDataSource()

        // Assert
        XCTAssertNotNil(ds)
        XCTAssertTrue(ds.rows.isEmpty)
    }

    func testSetUpDataSource() throws {
        // Arrange
        let factory = TableViewCellFactoryMock()
        let dataSource = TableViewDataSource(cellFactory: factory)
        let tableView = UITableView()

        // Act
        dataSource.setUpDataSource(using: tableView)

        // Assert
        XCTAssertEqual((tableView.dataSource as! TableViewDataSource), dataSource)
        XCTAssertEqual(factory.tableView, tableView)
        XCTAssertTrue(dataSource.rows.isEmpty)
    }

    func testItemsAtSection() throws {
        // Arrange
        dataSource.rows = [jorgeBen]

        // Act
        let items = dataSource.items(at: 0)

        // Assert
        XCTAssertNotNil(items)
        XCTAssertEqual(items?.count, 1)
        XCTAssertEqual(items?[0], jorgeBen)
    }

    func testNumberOfSections() throws {
        // Arrange
        let tableView = UITableView()

        // Act
        let n = dataSource.numberOfSections(in: tableView)

        // Assert
        XCTAssertEqual(n, 1)
    }

    func testNumberOfRowsInSection() throws {
        // Arrange
        let tableView = UITableView()
        dataSource.rows = [jorgeBen]

        // Act
        let n = dataSource.tableView(tableView, numberOfRowsInSection: 1)

        // Assert
        XCTAssertEqual(n, 1)
    }

    func testCellForRowAtIndexPath() throws {
        // Arrange
        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)

        let factory = TableViewCellFactoryMock()
        let dataSource = TableViewDataSource(cellFactory: factory)
        dataSource.rows = [jorgeBen]

        // Act
        let cell = dataSource.tableView(tableView, cellForRowAt: indexPath)

        // Assert
        XCTAssertEqual(factory.indexPath, indexPath)
        XCTAssertEqual(factory.item as! Album, jorgeBen)
        XCTAssertEqual(factory.tableView, tableView)
        XCTAssertTrue(cell is AlbumCell)
    }

}

private class TableViewCellFactoryMock: TableViewCellFactory {

    var tableView: UITableView!
    var indexPath: IndexPath!
    var item: Any!

    override func registerCells(for tableView: UITableView) {
        self.tableView = tableView
    }

    override func cell(for indexPath: IndexPath, item: Any?, tableView: UITableView) -> UITableViewCell {
        self.indexPath = indexPath
        self.item = item
        self.tableView = tableView
        return AlbumCell()
    }

}
