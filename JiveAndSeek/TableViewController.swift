//
//  TableViewController.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-05-28.
//

import UIKit

class TableViewController: UITableViewController {

    var albumDetailsView: AlbumDetailsView?
    var dataSource: TableViewDataSource?
    var searchController: UISearchController?

    let searchQueue: OperationQueue = {
        let queue = OperationQueue.serialQueue(with: "SearchQueue")
        queue.qualityOfService = .userInitiated
        return queue
    }()

    let artworkQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "ArtworkQueue"
        queue.qualityOfService = .utility
        return queue
    }()

    // MARK: UIViewController

    override func loadView() {
        let dataSource = TableViewDataSource()
        self.dataSource = dataSource
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.rowHeight = 60
        self.tableView = tableView
        self.view = self.tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController?.searchResultsUpdater = self
        searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.searchBar.placeholder = NSLocalizedString("table.view.controller.search.placeholder", value: "Search for Band, Singer, or Artist", comment: "The search bar's placeholder text")
        navigationItem.searchController = searchController

        albumDetailsView = AlbumDetailsView()

        guard let tableView = self.tableView else { return }
        dataSource?.setUpDataSource(using: tableView)
        self.tableView?.delegate = self

    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let item = self.dataSource?.item(at: indexPath) else { return }
        albumDetailsView?.showAlert(with: item, on: self)

    }

}

extension TableViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }

        guard text != "" else {
            searchQueue.cancelAllOperations()
            artworkQueue.cancelAllOperations()
            dataSource?.rows = []
            tableView.reloadData()
            return
        }

        // cancel any previous operations
        if searchQueue.operations.count > 0 {
            searchQueue.cancelAllOperations()
            artworkQueue.cancelAllOperations()
        }

        // debounce: delay launching a network request in case the user is typing quickly (to not launch unnecessary requests and not overload the API)
        let debounceOperation = DelayOperation(interval: 0.5)
        let fetchOperation = FetchAlbumsOperation(artistSearchQuery: text)
        let parseOperation = ParseAlbumsOperation()

        let adapterOperation = BlockOperation { [unowned parseOperation] in
            parseOperation.response = fetchOperation.response
        }

        let dispatchOperation = DispatchArtworkOperation(queue: artworkQueue, dataSource: dataSource)

        let artworkAdapterOperation = BlockOperation { [unowned dispatchOperation] in
            dispatchOperation.albums = parseOperation.results
        }

        let updateViewOperation = BlockOperation { [unowned self] in
            DispatchQueue.main.async {
                self.updateRows(with: parseOperation.results)
            }
        }

        searchQueue.addOperations([debounceOperation, fetchOperation, adapterOperation, parseOperation, artworkAdapterOperation, dispatchOperation, updateViewOperation], waitUntilFinished: false)
    }

    func updateRows(with results: [Album]) {
        var rows = results

        if results.isEmpty {
            let image = UIImage(systemName: "slash.circle")?.withTintColor(.gray, renderingMode: .alwaysOriginal)
            let noResults = Album(name: NSLocalizedString("table.view.controller.no.results.found", value: "No Albums Found", comment: "The search query returned no results."), artwork: image, artworkUrl: nil, releaseDate: nil, genre: nil, price: nil, currency: nil, copyright: nil)
            rows = [noResults]
        }

        dataSource?.rows = rows
        tableView.reloadData()
    }

}

extension TableViewController: UISearchBarDelegate {

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchQueue.cancelAllOperations()
        artworkQueue.cancelAllOperations()
    }

}
