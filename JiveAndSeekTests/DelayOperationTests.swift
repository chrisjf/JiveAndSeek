//
//  DelayOperationTests.swift
//  JiveAndSeekTests
//
//  Created by Christopher Forbes on 2021-06-03.
//

@testable import JiveAndSeek
import XCTest

class DelayOperationTests: XCTestCase {

    private var queue: OperationQueue!

    override func setUpWithError() throws {
        queue = OperationQueue.serialQueue(with: "\(self)Queue")
        queue.qualityOfService = .userInitiated
    }

    override func tearDownWithError() throws {
        queue = nil
    }

    func testCreationInterval() throws {
        // Act
        let op = DelayOperation(interval: TimeInterval(0.5))

        // Assert
        XCTAssertNotNil(op)
    }

    func testCreationDate() throws {
        // Act
        let op = DelayOperation(until: Date(timeIntervalSinceNow: 0.5))

        // Assert
        XCTAssertNotNil(op)
    }

    // The below tests were adapted from PSOperations:
    // https://github.com/pluralsight/PSOperations/blob/master/PSOperationsTests/PSOperationsTests.swift

    func testDelayOperation() throws {
        // Arrange
        let delay: TimeInterval = 0.1

        let then = Date()
        let op = DelayOperation(interval: delay)

        keyValueObservingExpectation(for: op, keyPath: "isFinished") { op, _ in
            if let op = op as? Foundation.Operation {
                return op.isFinished
            }
            return false
        }

        // Act
        queue.addOperation(op)

        // Assert
        waitForExpectations(timeout: delay + 2) { _ in
            let now = Date()
            let diff = now.timeIntervalSince(then)
            XCTAssertTrue(diff >= delay, "Didn't delay long enough")
        }
    }

    func testDelayOperationWith0() throws {
        // Arrange
        let delay: TimeInterval = 0.0

        let then = Date()
        let op = DelayOperation(interval: delay)

        var done = false
        let lock = NSLock()

        keyValueObservingExpectation(for: op, keyPath: "isFinished") { op, _ in
            lock.lock()
            if let op = op as? Foundation.Operation, !done {
                done = op.isFinished
                lock.unlock()
                return op.isFinished
            }

            lock.unlock()

            return false
        }

        // Act
        queue.addOperation(op)

        // Assert
        waitForExpectations(timeout: delay + 2) { _ in
            let now = Date()
            let diff = now.timeIntervalSince(then)
            XCTAssertTrue(diff >= delay, "Didn't delay long enough")
        }
    }

    func testDelayOperationWithDate() throws {
        // Arrange
        let delay: TimeInterval = 1
        let date = Date().addingTimeInterval(delay)
        let op = DelayOperation(until: date)

        let then = Date()
        keyValueObservingExpectation(for: op, keyPath: "isFinished") { op, _ in
            if let op = op as? Foundation.Operation {
                return op.isFinished
            }

            return false
        }

        // Act
        queue.addOperation(op)

        // Assert
        waitForExpectations(timeout: delay + 2) { _ in
            let now = Date()
            let diff = now.timeIntervalSince(then)
            XCTAssertTrue(diff >= delay, "Didn't delay long enough")
        }
    }

    func testDelayOperationIsCancellableAndNotFinishedTillDelayTime() throws {
        // Arrange
        let exp = expectation(description: "")

        let delayOp = DelayOperation(interval: 2)
        let blockOp = BlockOperation {
            XCTAssertFalse(delayOp.isFinished)
            delayOp.cancel()
            exp.fulfill()
        }

        let q = OperationQueue()

        // Act
        q.addOperation(delayOp)
        q.addOperation(blockOp)

        // Assert
        keyValueObservingExpectation(for: delayOp, keyPath: "isCancelled") { op, _ in

            guard let op = op as? Foundation.Operation else { return false }

            return op.isCancelled
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

}
