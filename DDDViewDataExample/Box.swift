//
//  Box.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 24.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public struct BoxId: Equatable, DebugPrintable, Identifiable {
    public var identifier: IntegerId { return _identifier }
    private var _identifier: IntegerId
    
    public init(_ identifier: IntegerId) {
        _identifier = identifier
    }
    
    public var debugDescription: String {
        return "BoxId: \(identifier)"
    }
}

public func ==(lhs: BoxId, rhs: BoxId) -> Bool {
    return lhs.identifier == rhs.identifier
}

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBox(box: Box)
    func boxes() -> [Box]
    func boxWithId(boxId: BoxId) -> Box?
    func count() -> Int
}


public class Box: NSObject {
    public let boxId: BoxId
    public dynamic var title: String
    dynamic var items: [Item] = []
    
    public init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    public func addItem(item: Item) {
        assert(item.box == nil, "item should not have a parent box already")
        
        items.append(item)
    }
    
    public func item(#itemId: ItemId) -> Item? {
        for item in items {
            if item.itemId == itemId {
                return item
            }
        }
        
        return nil
    }
}
