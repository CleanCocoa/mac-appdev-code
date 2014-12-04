//
//  DomainEventPublisher.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

public enum DomainEventType: String {
    case BoxProvisioned = "Box Provisioned"
    case BoxItemProvisioned = "Box Item Provisioned"
    
    var name: String {
        return self.rawValue
    }
}

public protocol DomainEvent {
    init(userInfo: UserInfo)
    class var eventType: DomainEventType { get }
    func userInfo() -> UserInfo
    func notification() -> NSNotification
}

public class DomainEventPublisher {
    public class var sharedInstance: DomainEventPublisher {
        struct Static {
            static let instance: DomainEventPublisher = DomainEventPublisher()
        }
        return Static.instance
    }
    
    public class func resetSharedInstance() {
        sharedInstance.reset()
    }
    
    func reset() {
        _defaultCenter = nil
    }
    
    var _defaultCenter: NSNotificationCenter?
    
    public class func defaultCenter() -> NSNotificationCenter {
        return sharedInstance.defaultCenter()
    }
    
    public func setDefaultCenter(notificationCenter: NSNotificationCenter) {
        assert(_defaultCenter == nil, "defaultCenter can be set up only once. Call reset() if needed during tests")
        _defaultCenter = notificationCenter
    }
    
    public func defaultCenter() -> NSNotificationCenter {
        if _defaultCenter == nil {
            _defaultCenter = NSNotificationCenter.defaultCenter()
        }
        
        return _defaultCenter!
    }
    
    public func publish(event: DomainEvent) {
        defaultCenter().postNotification(event.notification())
    }
    
    public func subscribe<T: DomainEvent>(event: T.Type, queue: NSOperationQueue, usingBlock block: (T!) -> Void) -> NSObjectProtocol {
        let eventType: DomainEventType = T.eventType
        return defaultCenter().addObserverForName(eventType.name, object: nil, queue: queue) {
            (notification: NSNotification!) -> Void in
            
            let userInfo = notification.userInfo!
            let event: T = T(userInfo: userInfo)
            block(event)
        }
    }
    
    public func unsubscribe(subscriber: AnyObject) {
        defaultCenter().removeObserver(subscriber)
    }
}
