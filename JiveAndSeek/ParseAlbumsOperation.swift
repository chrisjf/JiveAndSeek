//
//  ParseAlbumsOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-05-28.
//

import Foundation
import os.log

class ParseAlbumsOperation: AsynchronousOperation {

    var response: Data?

    private(set) var results: [Album] = []

    override func execute() {
        guard !isCancelled else {
            finish()
            return
        }

        guard let json = response else {
            os_log("JSON data is nil", type: .error)
            finish()
            return
        }

        let searchResults: SearchResults
        do {
            searchResults = try SearchResults(data: json)
        } catch {
            os_log("JSON file was not decoded.", type: .error)
            finish()
            return
        }

        let albums = searchResults.results.map { result -> Album in
            var price: Decimal? = nil
            if let collectionPrice = result.collectionPrice {
                price = Decimal(collectionPrice)
            }
            return Album(name: result.collectionName,
                         artworkUrl: result.artworkUrl100,
                         releaseDate: result.releaseDate,
                         genre: result.primaryGenreName,
                         price: price,
                         currency: result.currency,
                         copyright: result.copyright)
        }

        results = albums
        finish()
    }

}
