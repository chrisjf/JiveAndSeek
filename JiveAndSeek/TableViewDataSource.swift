//
//  TableViewDataSource.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-03.
//

import UIKit

class TableViewDataSource: NSObject {

    var rows: [Album] = []
    weak var tableView: UITableView?

    private let cellFactory: TableViewCellFactory

    init(cellFactory: TableViewCellFactory = TableViewCellFactory()) {
        self.cellFactory = cellFactory
    }

    func setUpDataSource(using tableView: UITableView) {
        tableView.dataSource = self
        self.tableView = tableView
        self.cellFactory.registerCells(for: tableView)
        self.rows = []
    }

}

extension TableViewDataSource: DataSourceType {

    typealias Item = Album

    func items(at section: Int) -> [Album]? {
        return rows
    }

}

// MARK: UITableViewDataSource

extension TableViewDataSource: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items(at: section)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory.cell(for: indexPath, item: item(at: indexPath), tableView: tableView)
    }

}
