//
//  Item.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public struct ItemId: Equatable, DebugPrintable, Identifiable {
    public var identifier: IntegerId { return _identifier }
    private var _identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        _identifier = identifier
    }
    
    public var debugDescription: String {
        return "ItemId: \(identifier)"
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
    public let title: String
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
}
