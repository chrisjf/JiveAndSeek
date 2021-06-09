//
//  AlbumDetailsView.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-04.
//

import UIKit

class AlbumDetailsView {

    private let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.autoupdatingCurrent
        return formatter
    }()

    func showAlert(with album: Album, on viewController: UIViewController) {
        let genreTitle = NSLocalizedString("album.details.view.genre", value: "Primary Genre:", comment: "Album details")
        let priceTitle = NSLocalizedString("album.details.view.price", value: "Price:", comment: "Album details")
        let copyrightTitle = NSLocalizedString("album.details.view.copyright", value: "Copyright:", comment: "Album details")

        let unknown = NSLocalizedString("album.details.view.unknown", value: "Unknown", comment: "Album detail is unknown")

        let genre = album.genre ?? unknown

        var price: String = unknown
        if let thePrice = album.price,
           let currency = album.currency {
            price = priceFormatter.string(from: thePrice as NSDecimalNumber) ?? unknown
            price = String(format: NSLocalizedString("album.details.view.price.format", value: "%@ %@", comment: "Price + Currency Code, e.g. $9.99 USD"), price, currency)
        }

        let copyright = album.copyright ?? unknown

        let message = String(format: NSLocalizedString("album.details.view.details.format", value: "\n%@ %@\n\n%@ %@\n\n%@ %@", comment: "Album details grouped together. e.g. Primary Genre: Pop\nPrice: $9.99 CAD\nCopyright: 2000"),
                             genreTitle,
                             genre,
                             priceTitle,
                             price,
                             copyrightTitle,
                             copyright)

        let title = String(format: NSLocalizedString("album.details.view.title", value: "Album Details:\n%@", comment: "Alert title"), album.name)

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("album.details.view.ok", value: "OK", comment: "Dismiss alert button"), style: .default, handler: nil))

        viewController.present(alert, animated: true, completion: nil)
    }

}
