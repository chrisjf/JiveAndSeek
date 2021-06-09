//
//  SearchResults.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-05-28.
//

import Foundation

// This file was generated from JSON Schema using quicktype.io

// MARK: - SearchResults

struct SearchResults: Codable {

    let resultCount: Int
    let results: [Result]

}

// MARK: SearchResults convenience initializers and mutators

extension SearchResults {

    init(data: Data) throws {
        self = try newJSONDecoder().decode(SearchResults.self, from: data)
    }

}

// MARK: - Result

struct Result: Codable {

    let wrapperType: String
    let collectionType: String
    let collectionID: Int
    let artistName: String?
    let collectionName: String
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionPrice: Double?
    let copyright: String?
    let currency: String
    let releaseDate: Date
    let primaryGenreName: String

    enum CodingKeys: String, CodingKey {
        case wrapperType
        case collectionType
        case collectionID = "collectionId"
        case artistName, collectionName
        case artworkUrl60, artworkUrl100, collectionPrice, copyright, currency, releaseDate, primaryGenreName
    }

}

// MARK: - Helpers

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}
