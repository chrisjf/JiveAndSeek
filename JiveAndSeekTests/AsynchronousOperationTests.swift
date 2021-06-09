//
//  AsynchronousOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-05-31.
//

@testable import JiveAndSeek
import XCTest

class AsynchronousOperationTests: XCTestCase {

    func testCreation() throws {
        // Act
        let op = AsynchronousOperation()

        // Assert
        XCTAssertNotNil(op)
        XCTAssertEqual(op.isAsynchronous, true)
        XCTAssertEqual(op.isReady, true)
        XCTAssertEqual(op.isExecuting, false)
        XCTAssertEqual(op.isFinished, false)
        XCTAssertEqual(op.isCancelled, false)
    }

    func testStart() throws {
        // Arrange
        let op = AsyncOperationMock()

        // Act
        op.start()

        // Assert
        XCTAssertEqual(op.isExecuting, true)
        XCTAssertEqual(op.isFinished, false)
        XCTAssertEqual(op.isCancelled, false)
    }

    func testStartIsCancelled() throws {
        // Arrange
        let op = AsyncOperationMock()
        op.cancel()

        // Act
        op.start()

        // Assert
        XCTAssertEqual(op.isExecuting, false)
        XCTAssertEqual(op.isFinished, true)
        XCTAssertEqual(op.isCancelled, true)
    }

    func testExecute() throws {
        // Arrange
        let op = AsyncOperationMock()
        var didExecute = false
        op.executeBlock = {
            didExecute = true
        }

        // Act
        op.start()

        // Assert
        XCTAssertEqual(didExecute, true)
        XCTAssertEqual(op.isExecuting, true)
        XCTAssertEqual(op.isFinished, false)
        XCTAssertEqual(op.isCancelled, false)
    }

    func testFinish() throws {
        // Arrange
        let op = AsyncOperationMock()

        // Act
        op.finish()

        // Assert
        XCTAssertEqual(op.isExecuting, false)
        XCTAssertEqual(op.isFinished, true)
        XCTAssertEqual(op.isCancelled, false)
    }

    func testCancel() throws {
        // Arrange
        let op = AsyncOperationMock()

        // Act
        op.cancel()

        // Assert
        XCTAssertEqual(op.isExecuting, false)
        XCTAssertEqual(op.isFinished, false)
        XCTAssertEqual(op.isCancelled, true)
    }

    func testSerialQueue() throws {
        // Act
        let q = OperationQueue.serialQueue(with: "TestQueue")

        // Assert
        XCTAssertNotNil(q)
        XCTAssertEqual(q.maxConcurrentOperationCount, 1)
        XCTAssertEqual(q.name, "TestQueue")
    }

}

private class AsyncOperationMock: AsynchronousOperation {

    var executeBlock: (() -> Void)?

    override func execute() {
        executeBlock?()
    }

}
