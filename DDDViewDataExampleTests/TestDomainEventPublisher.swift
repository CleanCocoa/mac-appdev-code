//
//  TestDomainEventPublisher.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

import DDDViewDataExample

/// Overrides `NSNotificationCenter` methods with no-op stubs
class NullNotificationCenter: NSNotificationCenter {
    override func addObserverForName(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification) -> Void) -> NSObjectProtocol {
        return NSObject()
    }
    
    override func removeObserver(observer: AnyObject) {
        // no op
    }
    
    override func postNotification(notification: NSNotification) {
        // no op
    }
}

/// Doesn't actually notify anyone thanks to the no-op `NullNotificationCenter`.
class TestDomainEventPublisher: DomainEventPublisher {
    init() {
        super.init(notificationCenter: NullNotificationCenter())
    }
}

class MockDomainEventPublisher: TestDomainEventPublisher {
    var lastPublishedEvent: DomainEvent?
    
    override func publish(event: DomainEvent) {
        lastPublishedEvent = event
    }
}
