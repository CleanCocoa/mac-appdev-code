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
    /// The `DomainEventType` to identify this kind of DomainEvent
    class var eventType: DomainEventType { get }
    
    init(userInfo: UserInfo)
    func userInfo() -> UserInfo
    func notification() -> NSNotification
}

private struct DomainEventPublisherStatic {
    static var singleton: DomainEventPublisher? = nil
    static var onceToken: dispatch_once_t = 0
}

public class DomainEventPublisher {
    public class var sharedInstance: DomainEventPublisher {
        if DomainEventPublisherStatic.singleton == nil {
            dispatch_once(&DomainEventPublisherStatic.onceToken) {
                self.setSharedInstance(DomainEventPublisher())
            }
        }
        
        return DomainEventPublisherStatic.singleton!
    }
    
    /// Reset the static `sharedInstance`, for example for testing
    public class func resetSharedInstance() {
        DomainEventPublisherStatic.singleton = nil
        DomainEventPublisherStatic.onceToken = 0
    }
    
    public class func setSharedInstance(instance: DomainEventPublisher) {
        DomainEventPublisherStatic.singleton = instance
    }

    let notificationCenter: NSNotificationCenter
    
    public convenience init() {
        self.init(notificationCenter: NSNotificationCenter.defaultCenter())
    }
    
    public init(notificationCenter: NSNotificationCenter) {
        self.notificationCenter = notificationCenter
        NSLog("init")
    }
    
    //MARK: -
    //MARK: Event Publishing and Subscribing
    
    public func publish(event: DomainEvent) {
        notificationCenter.postNotification(event.notification())
    }
    
    public func subscribe<T: DomainEvent>(event: T.Type, queue: NSOperationQueue, usingBlock block: (T!) -> Void) -> NSObjectProtocol {
        let eventType: DomainEventType = T.eventType
        return notificationCenter.addObserverForName(eventType.name, object: nil, queue: queue) {
            (notification: NSNotification!) -> Void in
            
            let userInfo = notification.userInfo!
            let event: T = T(userInfo: userInfo)
            block(event)
        }
    }
    
    public func unsubscribe(subscriber: AnyObject) {
        notificationCenter.removeObserver(subscriber)
    }
}
