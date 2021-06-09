//
//  AlbumTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-28.
//

@testable import JiveAndSeek
import XCTest

class AlbumTests: XCTestCase {

    func testCreation() throws {
        // Arrange
        let name = "Paris Tristesse"
        let artworkUrl = "https://pierrelapointe.com/albums/paris-tristesse/"
        let releaseDate = Date(timeIntervalSince1970: 1423555200)
        let genre = "Musique francophone"
        let price = Decimal(9.99)
        let currency = "CAD"
        let copyright = "℗ 2014 Les Disques Audiogramme inc."

        // Act
        let a = Album(name: name,
                      artwork: UIImage(systemName: "pianokeys"),
                      artworkUrl: artworkUrl,
                      releaseDate: releaseDate,
                      genre: genre,
                      price: price,
                      currency: currency,
                      copyright: copyright)

        // Assert
        XCTAssertNotNil(a)
        XCTAssertEqual(a.name, name)
        XCTAssertEqual(a.artworkUrl, artworkUrl)
        XCTAssertEqual(a.releaseDate, releaseDate)
        XCTAssertEqual(a.genre, genre)
        XCTAssertEqual(a.price, price)
        XCTAssertEqual(a.currency, currency)
        XCTAssertEqual(a.copyright, copyright)
    }

    func testCompare() throws {
        // Arrange
        let name = "Paris Tristesse"
        let artworkUrl = "https://pierrelapointe.com/albums/paris-tristesse/"
        let releaseDate = Date(timeIntervalSince1970: 1423555200)
        let genre = "Musique francophone"
        let price = Decimal(9.99)
        let currency = "CAD"
        let copyright = "℗ 2014 Les Disques Audiogramme inc."

        let a = Album(name: name,
                      artwork: nil,
                      artworkUrl: artworkUrl,
                      releaseDate: releaseDate,
                      genre: genre,
                      price: price,
                      currency: currency,
                      copyright: copyright)

        let b = Album(name: name,
                      artwork: nil,
                      artworkUrl: artworkUrl,
                      releaseDate: releaseDate,
                      genre: genre,
                      price: price,
                      currency: currency,
                      copyright: copyright)

        // Act
        let result = a == b

        // Assert
        XCTAssertEqual(result, true)
    }

    func testCompareFalse() throws {
        // Arrange
        let a = Album(name: "Paris Tristesse",
                      artwork: UIImage(systemName: "pianokeys"),
                      artworkUrl: "https://pierrelapointe.com/albums/paris-tristesse/",
                      releaseDate: Date(timeIntervalSince1970: 1423555200),
                      genre: "Musique francophone",
                      price: Decimal(9.99),
                      currency: "CAD",
                      copyright: "℗ 2014 Les Disques Audiogramme inc.")

        let b = Album(name: "A Tábua de Esmeralda",
                      artwork: UIImage(systemName: "music.note"),
                      artworkUrl: "http://jorgebenjor.com.br/",
                      releaseDate: Date(timeIntervalSince1970: 126259200),
                      genre: "MPB",
                      price: Decimal(9.99),
                      currency: "CAD",
                      copyright: "℗ 1974 Universal Music Ltda")

        // Act
        let result = a == b

        // Assert
        XCTAssertEqual(result, false)
    }

}
