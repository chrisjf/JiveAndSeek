//
//  ParseAlbumsOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-31.
//

@testable import JiveAndSeek
import XCTest

class ParseAlbumsOperationTests: XCTestCase {

    private var operation: ParseAlbumsOperation!

    override func setUpWithError() throws {
        operation = ParseAlbumsOperation()
    }

    override func tearDownWithError() throws {
        operation = nil
    }

    func testCreation() throws {
        // Act
        let op = ParseAlbumsOperation()

        // Assert
        XCTAssertNotNil(op)
    }

    func testExecute() throws {
        // Arrange
        let json = """
            {
             "resultCount":4,
             "results": [
            {"wrapperType":"collection", "collectionType":"Album", "artistId":90233463, "collectionId":713573779, "amgArtistId":485354, "artistName":"Mamonas Assassinas", "collectionName":"Mamonas Assassinas - Ao Vivo", "collectionCensoredName":"Mamonas Assassinas - Ao Vivo", "artistViewUrl":"https://music.apple.com/ca/artist/mamonas-assassinas/90233463?uo=4", "collectionViewUrl":"https://music.apple.com/ca/album/mamonas-assassinas-ao-vivo/713573779?uo=4", "artworkUrl60":"https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/60x60bb.jpg", "artworkUrl100":"https://is5-ssl.mzstatic.com/image/thumb/Music125/v4/f8/23/02/f8230276-dc8e-bc82-a2b1-3335a57675f2/source/100x100bb.jpg", "collectionPrice":9.99, "collectionExplicitness":"notExplicit", "trackCount":16, "copyright":"℗ 2006 EMI Music Brasil Ltda", "country":"CAN", "currency":"CAD", "releaseDate":"2006-01-01T08:00:00Z", "primaryGenreName":"MPB"},
            {"wrapperType":"collection", "collectionType":"Album", "artistId":90233463, "collectionId":1489396925, "amgArtistId":485354, "artistName":"Mamonas Assassinas, Vivi Seixas & Nytron", "collectionName":"Mundo Animal (Remix) - Single", "collectionCensoredName":"Mundo Animal (Remix) - Single", "artistViewUrl":"https://music.apple.com/ca/artist/mamonas-assassinas/90233463?uo=4", "collectionViewUrl":"https://music.apple.com/ca/album/mundo-animal-remix-single/1489396925?uo=4", "artworkUrl60":"https://is2-ssl.mzstatic.com/image/thumb/Music113/v4/14/67/a0/1467a0e1-a093-5c7b-f7ee-3cc1ad1a1ba3/source/60x60bb.jpg", "artworkUrl100":"https://is2-ssl.mzstatic.com/image/thumb/Music113/v4/14/67/a0/1467a0e1-a093-5c7b-f7ee-3cc1ad1a1ba3/source/100x100bb.jpg", "collectionPrice":1.29, "collectionExplicitness":"explicit", "contentAdvisoryRating":"Explicit", "trackCount":1, "copyright":"℗ 2019 EMI Records Brasil Ltda", "country":"CAN", "currency":"CAD", "releaseDate":"2019-12-20T08:00:00Z", "primaryGenreName":"Pop"},
            {"wrapperType":"collection", "collectionType":"Album", "artistId":1390624514, "collectionId":1390624308, "amgArtistId":3489849, "artistName":"Ruy Brissac & Mamonas Assassinas", "collectionName":"Vai Aê - Single", "collectionCensoredName":"Vai Aê - Single", "artistViewUrl":"https://music.apple.com/ca/artist/ruy-brissac/1390624514?uo=4", "collectionViewUrl":"https://music.apple.com/ca/album/vai-a%C3%AA-single/1390624308?uo=4", "artworkUrl60":"https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/a7/46/f3/a746f302-669a-6ffb-2b0f-93b89e29163a/source/60x60bb.jpg", "artworkUrl100":"https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/a7/46/f3/a746f302-669a-6ffb-2b0f-93b89e29163a/source/100x100bb.jpg", "collectionPrice":1.29, "collectionExplicitness":"notExplicit", "trackCount":1, "copyright":"℗ 2018 Mamonas Assassinas Produções, under exclusive license to Universal Music International", "country":"CAN", "currency":"CAD", "releaseDate":"2018-06-01T07:00:00Z", "primaryGenreName":"Rock"},
            {"wrapperType":"collection", "collectionType":"Album", "artistId":90233463, "collectionId":1444618999, "amgArtistId":485354, "artistName":"Mamonas Assassinas, Alok & Sevenn", "collectionName":"Pelados Em Santos - Single", "collectionCensoredName":"Pelados Em Santos - Single", "artistViewUrl":"https://music.apple.com/ca/artist/mamonas-assassinas/90233463?uo=4", "collectionViewUrl":"https://music.apple.com/ca/album/pelados-em-santos-single/1444618999?uo=4", "artworkUrl60":"https://is4-ssl.mzstatic.com/image/thumb/Music118/v4/a6/53/6e/a6536eee-50b2-442f-48e4-52b931c8ef77/source/60x60bb.jpg", "artworkUrl100":"https://is4-ssl.mzstatic.com/image/thumb/Music118/v4/a6/53/6e/a6536eee-50b2-442f-48e4-52b931c8ef77/source/100x100bb.jpg", "collectionPrice":1.29, "collectionExplicitness":"notExplicit", "trackCount":1, "copyright":"℗ 2017 Universal Music International", "country":"CAN", "currency":"CAD", "releaseDate":"2017-12-08T08:00:00Z", "primaryGenreName":"Pop"}]
            }
            """
        let data = json.data(using: .utf8)!
        operation.response = data

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(operation.results.count, 4)
    }

    func testExecuteIsCancelled() throws {
        // Arrange
        operation.cancel()

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(operation.results.count, 0)
        XCTAssertEqual(operation.isCancelled, true)
        XCTAssertEqual(operation.isFinished, true)
    }

    func testExecuteNoResponse() throws {
        // Arrange
        operation.response = nil

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(operation.results.count, 0)
        XCTAssertEqual(operation.isFinished, true)
    }

    func testExecuteMalformedJson() throws {
        // Arrange
        let json = """
            {
             "resultCount":1,
             "results": [
            {"wrapperType":"collection", "collectionType":"Album", "artistId":90233463, "collectionId":713573779
            }]
            }
            """
        let data = json.data(using: .utf8)!
        operation.response = data

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(operation.results.count, 0)
        XCTAssertEqual(operation.isFinished, true)
    }

    func testExecuteNoResults() throws {
        let json = """
            {
             "resultCount":0,
             "results": []
            }
            """
        let data = json.data(using: .utf8)!
        operation.response = data

        // Act
        operation.execute()

        // Assert
        XCTAssertEqual(operation.results.count, 0)
        XCTAssertEqual(operation.isFinished, true)
    }

}
