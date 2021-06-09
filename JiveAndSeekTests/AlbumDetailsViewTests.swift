//
//  AlbumDetailsViewTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-04.
//

@testable import JiveAndSeek
import XCTest

class AlbumDetailsViewTests: XCTestCase {

    func testCreation() throws {
        // Act
        let v = AlbumDetailsView()

        // Assert
        XCTAssertNotNil(v)
    }

    func testShowAlert() throws {
        // Arrange
        let a = Album(name: "Paris Tristesse",
                      artwork: UIImage(systemName: "music.note")!,
                      artworkUrl: "https://pierrelapointe.com/albums/paris-tristesse/",
                      releaseDate: Date(timeIntervalSince1970: 1423555200),
                      genre: "Musique francophone",
                      price: Decimal(9.99),
                      currency: "CAD",
                      copyright: "℗ 2014 Les Disques Audiogramme inc.")

        let vc = ViewControllerMock()
        let detailsView = AlbumDetailsView()

        // Act
        detailsView.showAlert(with: a, on: vc)

        // Assert
        XCTAssertNotNil(vc.controllerToPresent)
        XCTAssertNotNil(vc.animated)
        XCTAssertEqual(vc.animated, true)

        guard let alert = (vc.controllerToPresent as? UIAlertController) else {
            XCTFail()
            return
        }
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions[0].title, "OK")
        XCTAssertEqual(alert.title, "Album Details:\nParis Tristesse")
        XCTAssertEqual(alert.message, "\nPrimary Genre: Musique francophone\n\nPrice: $9.99 CAD\n\nCopyright: ℗ 2014 Les Disques Audiogramme inc.")
        XCTAssertEqual(alert.preferredStyle, .alert)
    }

    func testShowAlertWithoutPriceAndCopyright() throws {
        // Arrange
        let a = Album(name: "Paris Tristesse",
                      artwork: UIImage(systemName: "music.note")!,
                      artworkUrl: "https://pierrelapointe.com/albums/paris-tristesse/",
                      releaseDate: Date(timeIntervalSince1970: 1423555200),
                      genre: "Musique francophone",
                      price: nil,
                      currency: "CAD",
                      copyright: nil)

        let vc = ViewControllerMock()
        let detailsView = AlbumDetailsView()

        // Act
        detailsView.showAlert(with: a, on: vc)

        // Assert
        XCTAssertNotNil(vc.controllerToPresent)
        XCTAssertNotNil(vc.animated)
        XCTAssertEqual(vc.animated, true)

        guard let alert = (vc.controllerToPresent as? UIAlertController) else {
            XCTFail()
            return
        }
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions[0].title, "OK")
        XCTAssertEqual(alert.title, "Album Details:\nParis Tristesse")
        XCTAssertEqual(alert.message, "\nPrimary Genre: Musique francophone\n\nPrice: Unknown\n\nCopyright: Unknown")
        XCTAssertEqual(alert.preferredStyle, .alert)
    }

}

private class ViewControllerMock: UIViewController {

    var controllerToPresent: UIViewController!
    var animated: Bool!
    var completionBlock: (() -> Void)?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {

        controllerToPresent = viewControllerToPresent
        animated = flag
        completionBlock = completion
    }

}
