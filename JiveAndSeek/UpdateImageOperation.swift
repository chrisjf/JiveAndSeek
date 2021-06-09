//
//  UpdateImageOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-08.
//

import UIKit

// MARK: - Protocols for Dependency Injection

public protocol DispatchQueueProtocol {
    func async(execute work: @escaping @convention(block) () -> Void)
}

extension DispatchQueue: DispatchQueueProtocol {
    public func async(execute work: @escaping @convention(block) () -> Void) {
        async(group: nil, qos: .unspecified, flags: [], execute: work)
    }
}

// MARK: - UpdateImageOperation

class UpdateImageOperation: AsynchronousOperation {

    var image: UIImage? = nil

    private let album: Album
    private let dataSource: TableViewDataSource?
    private let dispatchQueue: DispatchQueueProtocol

    init(album: Album, dataSource: TableViewDataSource?, dispatchQueue: DispatchQueueProtocol = DispatchQueue.main) {
        self.album = album
        self.dataSource = dataSource
        self.dispatchQueue = dispatchQueue
    }

    override func execute() {
        guard !isCancelled else {
            finish()
            return
        }

        guard let image = image else {
            finish()
            return
        }

        guard let dataSource = self.dataSource else {
            finish()
            return
        }
        let rows = dataSource.rows

        // get the album, save the image on the album from dataSource.rows, call tableView.reloadRows
        for i in 0 ..< rows.count {
            if rows[i] == album {

                dispatchQueue.async {
                    guard !self.isCancelled else {
                        self.finish()
                        return
                    }

                    // ensure that the row still exists
                    guard let count = self.dataSource?.rows.count,
                          i < count,
                          self.dataSource?.rows[i] != nil else {
                        return
                    }

                    self.dataSource?.rows[i].artwork = image
                    guard let indexPath = dataSource.indexPath(for: self.album) else { return }
                    self.dataSource?.tableView?.reloadRows(at: [indexPath], with: .none)
                }
                break
            }
        }

        finish()
    }

}
