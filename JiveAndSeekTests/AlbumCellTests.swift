//
//  AlbumCellTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-31.
//

@testable import JiveAndSeek
import XCTest

class AlbumCellTests: XCTestCase {

    func testCreation() throws {
        // Arrange

        // Load the NIB from the bundle and grab the cell, in order to test that IBOutlets are correctly connected
        guard let objects = Bundle.main.loadNibNamed(String(describing: AlbumCell.self), owner: nil, options: nil) else {
            XCTFail()
            return
        }
        let cells = objects.compactMap {
            return ($0 as? AlbumCell) ?? nil
        }
        guard cells.count == 1 else {
            XCTFail()
            return
        }

        // Act
        guard let cell = cells.first else {
            XCTFail()
            return
        }

        // Assert
        XCTAssertNotNil(cell)
        XCTAssertNotNil(cell.artworkImageView)
        XCTAssertNotNil(cell.nameLabel)
        XCTAssertNotNil(cell.releaseDateLabel)
    }

}
