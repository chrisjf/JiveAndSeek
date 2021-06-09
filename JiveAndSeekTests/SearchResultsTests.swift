//
//  SearchResultsTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-28.
//

@testable import JiveAndSeek
import XCTest

// MARK: - SearchResults
class SearchResultsTests: XCTestCase {

    private let validJson = """
        {
         "resultCount":1,
         "results": [
        {"wrapperType":"collection", "collectionType":"Album", "artistId":90233463, "collectionId":713573779, "amgArtistId":485354, "artistName":"Mamonas Assassinas", "collectionName":"Mamonas Assassinas - Ao Vivo", "collectionCensoredName":"Mamonas Assassinas - Ao Vivo", "artistViewUrl":"https://music.apple.com/ca/artist/mamonas-assassinas/90233463?uo=4", "collectionViewUrl":"https://music.apple.com/ca/album/mamonas-assassinas-ao-vivo/713573779?uo=4", "artworkUrl60":"https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/60x60bb.jpg", "artworkUrl100":"https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/100x100bb.jpg", "collectionPrice":9.99, "collectionExplicitness":"notExplicit", "trackCount":16, "copyright":"℗ 2006 EMI Music Brasil Ltda", "country":"CAN", "currency":"CAD", "releaseDate":"2006-01-01T08:00:00Z", "primaryGenreName":"MPB"}
        ]}
        """

    func testCreation() throws {
        // Act
        let r = SearchResults(resultCount: 0, results: [])

        // Assert
        XCTAssertNotNil(r)
    }

    func testCreationData() throws {
        // Arrange
        let data = validJson.data(using: .utf8)!

        // Act
        let r = try SearchResults(data: data)

        // Assert
        XCTAssertEqual(r.resultCount, 1)
    }

}

// MARK: - Result
class ResultTests: XCTestCase {

    func testCreation() throws {
        // Act
        let r = Result(wrapperType: "collection",
                       collectionType: "Album",
                       collectionID: 713573779,
                       artistName: "Mamonas Assassinas",
                       collectionName: "Mamonas Assassinas - Ao Vivo",
                       artworkUrl60: "https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/60x60bb.jpg",
                       artworkUrl100: "https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/100x100bb.jpg",
                       collectionPrice: 9.99,
                       copyright: "℗ 2006 EMI Music Brasil Ltda",
                       currency: "CAD",
                       releaseDate: Date(timeIntervalSince1970: 1136102400),
                       primaryGenreName: "MPB")

        // Assert
        XCTAssertNotNil(r)
    }

}
