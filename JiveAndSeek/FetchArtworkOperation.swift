//
//  FetchArtworkOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-08.
//

import os.log
import UIKit

class FetchArtworkOperation: AsynchronousOperation {

    private(set) var response: UIImage?

    private let artworkUrl: String
    private let session: URLSessionProtocol
    private(set) var task: URLSessionDataTaskProtocol?

    init(artworkUrl: String, session: URLSessionProtocol = URLSession.shared) {
        self.artworkUrl = artworkUrl
        self.session = session
    }

    override func execute() {
        guard !isCancelled else {
            finish()
            return
        }

        downloadArtwork()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    private func downloadArtwork() {

        guard let endpoint = URL(string: artworkUrl) else {
            os_log("Fetch artwork failed. Invalid URL: %@", type: .error, artworkUrl)
            finish()
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"

        task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

            self.downloadArtworkResponse(data: data, response: response, error: error)

        }
        task?.resume()

    }

    private func downloadArtworkResponse(data: Data?, response: URLResponse?, error: Error?) {

        guard !isCancelled else {
            finish()
            return
        }

        guard error == nil else {
            if let error = error as NSError?,
               error.code == NSURLErrorCancelled && error.domain == NSURLErrorDomain {
                cancel()
                finish()
                return
            }

            os_log("Fetch artwork network error: %@", type: .error, error.debugDescription)
            finish()
            return
        }

        guard let data = data else {
            os_log("Fetched artwork but data was empty.", type: .error)
            finish()
            return
        }

        guard let image = UIImage(data: data) else {
            os_log("Fetched artwork but data was invalid and not converted into an image.", type: .error)
            finish()
            return
        }
        self.response = image
        finish()
    }

}
