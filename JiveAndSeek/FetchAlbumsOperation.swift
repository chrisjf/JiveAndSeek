//
//  FetchAlbumsOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-05-28.
//

import Foundation
import os.log

// MARK: - Protocols for Dependency Injection

protocol URLSessionProtocol {

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {

        return dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
    }

}

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

// MARK: - FetchAlbumsOperation

class FetchAlbumsOperation: AsynchronousOperation {

    private(set) var response: Data?

    private let artist: String
    private var locale: Locale
    private let session: URLSessionProtocol
    private(set) var task: URLSessionDataTaskProtocol?

    init(artistSearchQuery: String, session: URLSessionProtocol = URLSession.shared, locale: Locale = Locale.autoupdatingCurrent) {
        self.artist = artistSearchQuery
        self.session = session
        self.locale = locale
    }

    override func execute() {
        guard !isCancelled else {
            finish()
            return
        }

        downloadAlbums()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    func buildUrl() -> URL? {
        let countryCode = locale.regionCode ?? ""

        let queries = ["attribute": "artistTerm",
                       "country": countryCode,
                       "entity": "album",
                       "media": "music",
                       "term": artist]

        let items = queries.map { (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        }

        let baseUrl = "https://itunes.apple.com/search"

        guard var urlComps = URLComponents(string: baseUrl) else {
            os_log("Search URL components were not created.", type: .error)
            return nil
        }
        urlComps.queryItems = items

        guard let endpoint = urlComps.url else {
            os_log("Search URL was not created.", type: .error)
            return nil
        }
        return endpoint
    }

    private func downloadAlbums() {
        guard let endpoint = buildUrl() else {
            self.finish()
            return
        }

        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"

        task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in

            self.downloadAlbumsResponse(data: data, response: response, error: error)

        }
        task?.resume()
    }

    private func downloadAlbumsResponse(data: Data?, response: URLResponse?, error: Error?) {

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

            os_log("Fetch albums network error: %@", type: .error, error.debugDescription)
            finish()
            return
        }

        self.response = data
        finish()
    }

}
