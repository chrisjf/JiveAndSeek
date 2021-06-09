//
//  TableViewCellFactoryTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-04.
//

@testable import JiveAndSeek
import XCTest

class TableViewCellFactoryTests: XCTestCase {

    private var factory: TableViewCellFactory!

    override func setUpWithError() throws {
        factory = TableViewCellFactory()
    }

    override func tearDownWithError() throws {
        factory = nil
    }

    func testCreation() throws {
        // Act
        let f = TableViewCellFactory()

        // Assert
        XCTAssertNotNil(f)
    }

    func testCellIdentifier() throws {
        // Arrange
        let indexPath = IndexPath(row: 0, section: 0)
        let tableView = UITableView()

        // Act
        let cellId = factory.cellIdentifier(forRowAt: indexPath, in: tableView)

        // Assert
        XCTAssertEqual(cellId, String(describing: AlbumCell.self))
    }

    func testRegisterCells() throws {
        // Arrange
        let tableView = TableViewMock()

        // Act
        factory.registerCells(for: tableView)

        // Assert
        XCTAssertNotNil(tableView.nib)
        XCTAssertEqual(tableView.identifier, String(describing: AlbumCell.self))
    }

    func testCellForIndexPath() throws {
        // Arrange
        let indexPath = IndexPath(row: 0, section: 0)
        let image = UIImage(systemName: "music.note")!
        let jorgeBen = Album(name: "A Tábua de Esmeralda",
                             artwork: image,
                             artworkUrl: "http://jorgebenjor.com.br/",
                             releaseDate: Date(timeIntervalSince1970: 126259200),
                             genre: "MPB",
                             price: Decimal(9.99),
                             currency: "CAD",
                             copyright: "℗ 1974 Universal Music Ltda")
        let tableView = TableViewMock()

        // Act
        let tableViewCell = factory.cell(for: indexPath, item: jorgeBen, tableView: tableView)

        // Assert
        XCTAssertEqual(tableView.identifier, String(describing: AlbumCell.self))

        XCTAssertTrue(tableViewCell is AlbumCell)
        let cell = tableViewCell as! AlbumCell
        XCTAssertEqual(cell.artworkImageView.image, image)
        XCTAssertEqual(cell.nameLabel.text, "A Tábua de Esmeralda")
        XCTAssertEqual(cell.releaseDateLabel.text, "1/1/74")
    }

    func testCellForIndexPathWithoutImageAndDate() throws {
        // Arrange
        let indexPath = IndexPath(row: 0, section: 0)
        let image = UIImage(systemName: "opticaldisc")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
        let noResults = Album(name: "No Albums Found",
                              artwork: nil,
                              artworkUrl: nil,
                              releaseDate: nil,
                              genre: nil,
                              price: nil,
                              currency: nil,
                              copyright: nil)
        let tableView = TableViewMock()

        // Act
        let tableViewCell = factory.cell(for: indexPath, item: noResults, tableView: tableView)

        // Assert
        XCTAssertEqual(tableView.identifier, String(describing: AlbumCell.self))

        XCTAssertTrue(tableViewCell is AlbumCell)
        let cell = tableViewCell as! AlbumCell
        XCTAssertEqual(cell.artworkImageView.image, image)
        XCTAssertEqual(cell.nameLabel.text, "No Albums Found")
        XCTAssertTrue(cell.releaseDateLabel.text?.isEmpty == true)
    }

}

private class TableViewMock: UITableView {

    var nib: UINib!
    var identifier: String!

    override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        self.nib = nib
        self.identifier = identifier
    }

    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        self.identifier = identifier

        // Load the NIB from the bundle and grab the cell, in order to test that IBOutlets are correctly connected
        guard let objects = Bundle.main.loadNibNamed(String(describing: AlbumCell.self), owner: nil, options: nil) else {
            XCTFail()
            return nil
        }
        let cells = objects.compactMap {
            return ($0 as? AlbumCell) ?? nil
        }
        guard cells.count == 1 else {
            XCTFail()
            return nil
        }
        return cells[0]
    }

}
