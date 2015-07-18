//
//  Item.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public struct ItemId: Equatable, Hashable, CustomDebugStringConvertible, Identifiable {
    public var identifier: IntegerId { return _identifier }
    private var _identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        _identifier = identifier
    }
    
    init(_ identifierNumber: NSNumber) {
        _identifier = identifierNumber.longLongValue
    }
    
    public var debugDescription: String {
        return "ItemId: \(identifier)"
    }
    
    public var hashValue: Int {
        return self._identifier.hashValue
    }
}

public func ==(lhs: ItemId, rhs: ItemId) -> Bool {
    return lhs.identifier == rhs.identifier
}

public protocol ItemRepository {
    func nextId() -> ItemId
    func addItem(item: Item)
    func items() -> Array<Item>
    func count() -> UInt
}

public class Item: NSObject {
    public let itemId: ItemId
    public dynamic var title: String
    public var box: Box?
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if let other = object as? Item {
            return other.itemId == self.itemId
        }
        
        return false
    }
    
    public override var hashValue: Int {
        return 173 &+ self.itemId.hashValue
    }
}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.itemId == rhs.itemId
}
