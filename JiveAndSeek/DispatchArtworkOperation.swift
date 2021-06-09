//
//  DispatchArtworkOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-08.
//

import Foundation

class DispatchArtworkOperation: AsynchronousOperation {

    var albums: [Album] = []

    private let dataSource: TableViewDataSource?
    private let queue: OperationQueue

    init(queue: OperationQueue, dataSource: TableViewDataSource?) {
        self.dataSource = dataSource
        self.queue = queue
    }

    override func execute() {
        guard !isCancelled else {
            finish()
            return
        }
        guard !albums.isEmpty else {
            finish()
            return
        }

        var updateOperations: [Operation] = []
        for album in albums {
            guard let artworkUrl = album.artworkUrl,
                  !artworkUrl.isEmpty else {
                continue
            }

            let fetchOperation = FetchArtworkOperation(artworkUrl: artworkUrl)

            let imageOperation = UpdateImageOperation(album: album, dataSource: dataSource)

            let adapterOperation = BlockOperation { [unowned imageOperation] in
                imageOperation.image = fetchOperation.response
            }

            adapterOperation.addDependency(fetchOperation)
            imageOperation.addDependency(adapterOperation)

            updateOperations.append(fetchOperation)
            updateOperations.append(adapterOperation)
            updateOperations.append(imageOperation)
        }
        queue.addOperations(updateOperations, waitUntilFinished: false)
        finish()
    }

}
