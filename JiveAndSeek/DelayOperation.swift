//
//  DelayOperation.swift
//  JiveAndSeek
//
//  Created by Christopher Forbes on 2021-06-03.
//

/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
This file shows how to make an operation that efficiently waits.
*/

/*
LICENSE.txt

Sample code project: Advanced NSOperations
Version: 1.0

IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2015 Apple Inc. All Rights Reserved.
*/

import Foundation

/**
    `DelayOperation` is an `Operation` that will simply wait for a given time
    interval, or until a specific `NSDate`.

    It is important to note that this operation does **not** use the `sleep()`
    function, since that is inefficient and blocks the thread on which it is called.
    Instead, this operation uses `dispatch_after` to know when the appropriate amount
    of time has passed.

    If the interval is negative, or the `NSDate` is in the past, then this operation
    immediately finishes.
*/
class DelayOperation: AsynchronousOperation {

    // MARK: Types

    private enum Delay {
        case Interval(TimeInterval)
        case Date(Date)
    }

    // MARK: Properties

    private let delay: Delay

    // MARK: Initialization

    init(interval: TimeInterval) {
        delay = .Interval(interval)
        super.init()
    }

    init(until date: Date) {
        delay = .Date(date)
        super.init()
    }

    override func execute() {
        let interval: TimeInterval

        // Figure out how long we should wait for.
        switch delay {
            case .Interval(let theInterval):
                interval = theInterval

            case .Date(let date):
                interval = date.timeIntervalSinceNow
        }

        guard interval > 0 else {
            finish()
            return
        }

        let when = DispatchTime.now() + interval
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: when) { [weak self] in
            // If we were cancelled, then finish() has already been called.
            guard let strongSelf = self,
                  !strongSelf.isCancelled else {
                return
            }
            self?.finish()
        }
    }

    override func cancel() {
        // Cancelling the operation means we don't want to wait anymore.
        super.cancel()
        guard isExecuting else { return }
        self.finish()
    }
}
