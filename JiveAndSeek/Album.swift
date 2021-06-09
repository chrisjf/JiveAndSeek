//
//  Album.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-05-28.
//

import UIKit

struct Album {
    let name: String
    var artwork: UIImage?
    let artworkUrl: String?
    let releaseDate: Date?
    let genre: String?
    let price: Decimal?
    let currency: String?
    let copyright: String?

}

extension Album: Equatable {

    static func ==(lhs: Album, rhs: Album) -> Bool {
        return lhs.name == rhs.name && lhs.artworkUrl == rhs.artworkUrl && lhs.releaseDate == rhs.releaseDate && lhs.genre == rhs.genre && lhs.price == rhs.price && lhs.currency == rhs.currency && lhs.copyright == rhs.copyright
    }

}
