//
//  FetchArtworkOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-08.
//

@testable import JiveAndSeek
import XCTest

class FetchArtworkOperationTests: XCTestCase {

    private let artworkUrl = "https://is4-ssl.mzstatic.com/image/thumb/Music125/v4/66/b1/a4/66b1a4d2-db4b-f5a5-791a-d6d53696d21f/source/100x100bb.jpg"

    func testCreation() throws {
        // Act
        let op = FetchArtworkOperation(artworkUrl: "https://is4-ssl.mzstatic.com/image/thumb/Music125/v4/66/b1/a4/66b1a4d2-db4b-f5a5-791a-d6d53696d21f/source/100x100bb.jpg")

        // Assert
        XCTAssertNotNil(op)
    }

    func testExecute() throws {
        // Arrange
        let image = UIImage(systemName: "pianokeys")!
        let data = image.pngData()!
        let url = URL(string: artworkUrl)!
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!

        let mockTask = URLSessionDataTaskMock()
        mockTask.data = data
        mockTask.response = fakeResponse
        mockTask.error = nil

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteNoUrl() throws {
        // Arrange
        let op = FetchArtworkOperation(artworkUrl: "")

        // Act
        op.execute()

        // Assert
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteIsCancelled() throws {
        // Arrange
        let op = FetchArtworkOperation(artworkUrl: "")
        op.cancel()

        // Act
        op.execute()

        // Assert
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteIsCancelledDuringTask() throws {
        // Arrange
        let mockTask = URLSessionDataTaskMock()
        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        mockTask.cancelCompletion = {
            op.cancel()
        }

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
        guard let taskProtocol = op.task,
              let task = taskProtocol as? URLSessionDataTaskMock else {
            XCTFail()
            return
        }
        XCTAssertEqual(task.wasCancelled, true)
    }

    func testExecuteError() throws {
        // Arrange
        let error = URLError(.unknown)

        let mockTask = URLSessionDataTaskMock()
        mockTask.error = error

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteErrorCancelled() throws {
        // Arrange
        let error = URLError(.cancelled)

        let mockTask = URLSessionDataTaskMock()
        mockTask.error = error

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
        guard let taskProtocol = op.task,
              let task = taskProtocol as? URLSessionDataTaskMock else {
            XCTFail()
            return
        }
        XCTAssertEqual(task.wasCancelled, true)
    }

    func testExecuteNoData() throws {
        // Arrange
        let mockTask = URLSessionDataTaskMock()
        mockTask.data = nil

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteMalformedData() throws {
        // Arrange
        let mockTask = URLSessionDataTaskMock()
        mockTask.data = Data()

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchArtworkOperation(artworkUrl: artworkUrl, session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

}

private class URLSessionMock: URLSessionProtocol {

    var task: URLSessionDataTaskMock!

    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {

        if task == nil {
            task = URLSessionDataTaskMock()
        }

        task.completion = completionHandler

        guard let theTask: URLSessionDataTaskProtocol = task else {
            fatalError()
        }

        return theTask
    }

}

private class URLSessionDataTaskMock: URLSessionDataTaskProtocol {

    var data: Data?
    var response: URLResponse?
    var error: Error?

    var cancelCompletion: (() -> Void)?
    var wasCancelled = false

    var completion: ((Data?, URLResponse?, Error?) -> Void)!

    func resume() {
        if let cancelBlock = cancelCompletion {
            cancelBlock()
        }
        completion(data, response, error)
    }

    func cancel() {
        wasCancelled = true
    }

}
