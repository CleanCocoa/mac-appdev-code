//
//  BoxAndItemService.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 25.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class BoxAndItemService: HandlesItemListEvents {
    public init() { }

    public func provisionNewBoxId() -> BoxId {
        let repository = ServiceLocator.boxRepository()
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, title: "New Box")
        
        repository.addBox(box)
        
        return boxId
    }
    
    public func provisionNewItemId(inBox boxId: BoxId) -> ItemId {
//        This would be so wrong:
//
//        let repository = ServiceLocator.itemRepository()
//        let itemId = repository.nextId()
//        let item = Item(itemId: ItemId, title: "New Item")
//        
//        repository.addItem(item)
//        
//        return itemId
        return ItemId(0)
    }
}
