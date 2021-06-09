//
//  FetchAlbumsOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-28.
//

@testable import JiveAndSeek
import XCTest

class FetchAlbumsOperationTests: XCTestCase {

    func testCreation() throws {
        // Act
        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve")

        // Assert
        XCTAssertNotNil(op)
    }

    func testBuildUrl() throws {
        // Arrange
        let locale = Locale.autoupdatingCurrent
        let countryCode = locale.regionCode ?? ""
        let op = FetchAlbumsOperation(artistSearchQuery: "Mamonas Assassinas", locale: locale)

        // Act
        let url = op.buildUrl()

        // Assert
        XCTAssertNotNil(url)
        let correct = URL(string: "https://itunes.apple.com/search?attribute=artistTerm&country=" + countryCode + "&entity=album&media=music&term=Mamonas%20Assassinas")!

        XCTAssertEqual(url?.baseURL, correct.baseURL)

        let componentsCorrect = URLComponents(url: correct, resolvingAgainstBaseURL: false)
        let queryItemsCorrect = Set(componentsCorrect!.queryItems!)
        let components = URLComponents(url: url!, resolvingAgainstBaseURL: false)
        let queryItems = Set(components!.queryItems!)

        XCTAssertEqual(queryItems, queryItemsCorrect)
    }

    func testExecute() throws {
        // Arrange
        let data = Data()
        let url = URL(string: "https://test.com")!
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!

        let mockTask = URLSessionDataTaskMock()
        mockTask.data = data
        mockTask.response = fakeResponse
        mockTask.error = nil

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNotNil(op.response)
        XCTAssertEqual(op.response, data)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteIsCancelled() throws {
        // Arrange
        let mock = URLSessionMock()
        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)
        op.cancel()

        // Act
        op.execute()

        // Assert
        XCTAssertNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isCancelled, true)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteIsCancelledDuringTask() throws {
        // Arrange
        let mock = URLSessionMock()
        let mockTask = URLSessionDataTaskMock()
        mock.task = mockTask

        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)

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

    func testExecuteNoData() throws {
        // Arrange
        let url = URL(string: "https://test.com")!
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 204, httpVersion: "HTTP/1.1", headerFields: nil)!

        let mockTask = URLSessionDataTaskMock()
        mockTask.data = nil
        mockTask.response = fakeResponse
        mockTask.error = nil

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteError() throws {
        // Arrange
        let url = URL(string: "https://test.com")!
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: nil)!
        let error = URLError(.unknown)

        let mockTask = URLSessionDataTaskMock()
        mockTask.response = fakeResponse
        mockTask.error = error

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)

        // Act
        op.execute()

        // Assert
        XCTAssertNotNil(op.task)
        XCTAssertNil(op.response)
        XCTAssertEqual(op.isFinished, true)
    }

    func testExecuteErrorCancelled() throws {
        // Arrange
        let url = URL(string: "https://test.com")!
        let fakeResponse = HTTPURLResponse(url: url, statusCode: 400, httpVersion: "HTTP/1.1", headerFields: nil)!
        let error = URLError(.cancelled)

        let mockTask = URLSessionDataTaskMock()
        mockTask.response = fakeResponse
        mockTask.error = error

        let mock = URLSessionMock()
        mock.task = mockTask

        let op = FetchAlbumsOperation(artistSearchQuery: "Fauve", session: mock)

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

}

// Mocks inspired by: https://github.com/koromiko/Tutorial/blob/master/NetworkingUnitTest.playground/Contents.swift

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
