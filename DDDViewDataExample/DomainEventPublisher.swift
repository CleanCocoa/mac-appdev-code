//
//  DomainEventPublisher.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 04/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Foundation

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
}
