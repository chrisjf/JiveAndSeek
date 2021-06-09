//
//  TableViewControllerTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-28.
//

@testable import JiveAndSeek
import XCTest

class TableViewControllerTests: XCTestCase {

    private var controller: TableViewController!

    private let jorgeBen = Album(name: "A Tábua de Esmeralda",
                                 artwork: UIImage(systemName: "music.note")!,
                                 artworkUrl: "http://jorgebenjor.com.br/",
                                 releaseDate: Date(timeIntervalSince1970: 126259200),
                                 genre: "MPB",
                                 price: Decimal(9.99),
                                 currency: "CAD",
                                 copyright: "℗ 1974 Universal Music Ltda")

    override func setUpWithError() throws {
        controller = TableViewController()
    }

    override func tearDownWithError() throws {
        controller = nil
    }

    func testCreation() throws {
        // Act
        let vc = TableViewController()

        // Assert
        XCTAssertNotNil(vc)
        XCTAssertNotNil(vc.searchQueue)
        XCTAssertNotNil(vc.artworkQueue)
        XCTAssertNil(vc.dataSource)
        XCTAssertNil(vc.searchController)
        XCTAssertNil(vc.albumDetailsView)
    }

    func testLoadView() throws {
        // Act
        controller.loadView()

        // Assert
        XCTAssertNotNil(controller.dataSource)
        XCTAssertNotNil(controller.tableView)
        XCTAssertEqual(controller.tableView.frame, CGRect.zero)
        XCTAssertEqual(controller.tableView.style, .plain)
        XCTAssertEqual(controller.view, controller.tableView)
    }

    func testViewDidLoad() throws {
        // Arrange
        controller.loadView()
        let ds = TableViewDataSourceMock()
        controller.dataSource = ds

        // Act
        controller.viewDidLoad()

        // Assert
        XCTAssertNotNil(controller.searchController)
        XCTAssert((controller.searchController?.searchResultsUpdater as! NSObject) == controller)
        XCTAssertEqual(controller.searchController?.obscuresBackgroundDuringPresentation, false)
        XCTAssertEqual(controller.searchController?.searchBar.placeholder, "Search for Band, Singer, or Artist")
        XCTAssertEqual(controller.navigationItem.searchController, controller.searchController)

        XCTAssertNotNil(controller.albumDetailsView)

        XCTAssertTrue(ds.setUpWasCalled)
        XCTAssertEqual((controller.tableView.delegate as! NSObject), controller)
    }

    func testTableViewDidSelectRow() throws {
        // Arrange
        let ds = TableViewDataSourceMock()
        ds.rows = [jorgeBen]
        controller.dataSource = ds
        let tableView = UITableView()
        let indexPath = IndexPath(row: 0, section: 0)
        let alertMock = AlbumDetailsViewMock()
        controller.albumDetailsView = alertMock

        // Act
        controller.tableView(tableView, didSelectRowAt: indexPath)

        // Assert
        XCTAssertTrue(alertMock.showAlertWasCalled)
        XCTAssertEqual(alertMock.wasCalledWithAlbum, jorgeBen)
        XCTAssertEqual(alertMock.wasCalledWithViewController, controller)
    }

    func testUpdateSearchResults() throws {
        // Arrange
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.text = "Coldplay"
        controller.searchController = searchController
        controller.searchQueue.isSuspended = true

        // Act
        controller.updateSearchResults(for: searchController)

        // Assert
        XCTAssertEqual(controller.searchQueue.operations.count, 7)
        let operations = controller.searchQueue.operations
        XCTAssertTrue(operations[0] is DelayOperation)
        XCTAssertTrue(operations[1] is FetchAlbumsOperation)
        XCTAssertTrue(operations[2] is BlockOperation)
        XCTAssertTrue(operations[3] is ParseAlbumsOperation)
        XCTAssertTrue(operations[4] is BlockOperation)
        XCTAssertTrue(operations[5] is DispatchArtworkOperation)
        XCTAssertTrue(operations[6] is BlockOperation)
    }

    func testUpdateSearchResultsAndCancelPriorOperations() throws {
        // Arrange
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.text = "Coldplay"
        controller.searchController = searchController

        controller.searchQueue.isSuspended = true
        let testOp = BlockOperation {}
        controller.searchQueue.addOperation(testOp)

        controller.artworkQueue.isSuspended = true
        let testOp2 = BlockOperation {}
        controller.artworkQueue.addOperation(testOp2)

        // Act
        controller.updateSearchResults(for: searchController)

        // Assert
        XCTAssertEqual(controller.searchQueue.operations.count, 8)
        let operations = controller.searchQueue.operations
        XCTAssertEqual(operations[0], testOp)
        XCTAssertTrue(operations[0].isCancelled)
        for i in 1...5 {
            XCTAssertFalse(operations[i].isCancelled)
        }

        XCTAssertEqual(controller.artworkQueue.operations.count, 1)
        XCTAssertTrue(controller.artworkQueue.operations[0].isCancelled)
    }

    func testUpdateSearchResultsWithEmptyText() throws {
        // Arrange
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.text = ""
        controller.searchController = searchController

        controller.searchQueue.isSuspended = true
        let testOp = BlockOperation {}
        controller.searchQueue.addOperation(testOp)

        controller.artworkQueue.isSuspended = true
        let testOp2 = BlockOperation {}
        controller.artworkQueue.addOperation(testOp2)

        let ds = TableViewDataSourceMock()
        ds.rows = [jorgeBen]
        controller.dataSource = ds

        let tableView = TableViewMock()
        controller.tableView = tableView

        // Act
        controller.updateSearchResults(for: searchController)

        // Assert
        XCTAssertEqual(controller.searchQueue.operations.count, 1)
        XCTAssertTrue(testOp.isCancelled)
        XCTAssertTrue(testOp2.isCancelled)
        XCTAssertTrue(ds.rows.isEmpty)
        XCTAssertTrue(tableView.reloadWasCalled)
    }

    func testUpdateRows() throws {
        // Arrange
        let ds = TableViewDataSourceMock()
        controller.dataSource = ds

        let tableView = TableViewMock()
        controller.tableView = tableView

        // Act
        controller.updateRows(with: [jorgeBen])

        // Assert
        XCTAssertEqual(ds.rows.count, 1)
        XCTAssertEqual(ds.rows[0].name, "A Tábua de Esmeralda")
        XCTAssertTrue(tableView.reloadWasCalled)
    }

    func testUpdateRowsEmpty() throws {
        // Arrange
        let ds = TableViewDataSourceMock()
        controller.dataSource = ds

        let tableView = TableViewMock()
        controller.tableView = tableView

        // Act
        controller.updateRows(with: [])

        // Assert
        XCTAssertEqual(ds.rows.count, 1)
        XCTAssertEqual(ds.rows[0].name, "No Albums Found")
        XCTAssertTrue(tableView.reloadWasCalled)
    }

    func testSearchBarCancelButtonClicked() throws {
        // Arrange
        controller.searchQueue.isSuspended = true
        let testOp = BlockOperation {}
        controller.searchQueue.addOperation(testOp)

        controller.artworkQueue.isSuspended = true
        let testOp2 = BlockOperation {}
        controller.artworkQueue.addOperation(testOp2)

        let bar = UISearchBar()

        // Act
        controller.searchBarCancelButtonClicked(bar)

        // Assert
        XCTAssertTrue(testOp.isCancelled)
        XCTAssertTrue(testOp2.isCancelled)
    }

}

private class TableViewDataSourceMock: TableViewDataSource {

    var setUpWasCalled = false

    override func setUpDataSource(using tableView: UITableView) {
        setUpWasCalled = true
    }

}

private class AlbumDetailsViewMock: AlbumDetailsView {

    var showAlertWasCalled = false
    var wasCalledWithAlbum: Album!
    var wasCalledWithViewController: UIViewController!

    override func showAlert(with album: Album, on viewController: UIViewController) {
        showAlertWasCalled = true
        wasCalledWithAlbum = album
        wasCalledWithViewController = viewController
    }

}

private class TableViewMock: UITableView {

    var reloadWasCalled = false

    override func reloadData() {
        reloadWasCalled = true
    }

}
