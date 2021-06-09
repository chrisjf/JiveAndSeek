//
//  AsynchronousOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2016-06-29.
//

import Foundation

// Inspired by:
// - Advanced NSOperations - WWDC 2015 https://developer.apple.com/videos/play/wwdc2015/226/
// - Having Fun with NSOperations in iOS http://lorenzoboaro.io/2016/01/05/having-fun-with-operation-in-ios.html

class AsynchronousOperation: Operation {

    override var isAsynchronous: Bool {
        return true
    }

    fileprivate var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }

    override var isExecuting: Bool {
        return _executing
    }

    fileprivate var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }

        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }

    override var isFinished: Bool {
        return _finished
    }

    override func start() {
        super.start()
        guard !isCancelled else {
            finish()
            return
        }
        _executing = true
        execute()
    }

    func execute() {
        // Execute your async task here.
        print("\(self) must override 'execute'.")
        finish()
    }

    func finish() {
        // Notify the completion of async task and hence the completion of the operation
        _executing = false
        _finished = true
    }

}

extension OperationQueue {

    static func serialQueue(with name: String) -> OperationQueue {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.name = name
        return queue
    }

}
