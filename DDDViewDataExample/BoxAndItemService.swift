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
        let repository = ServiceLocator.boxRepository()
        let itemId = repository.nextItemId()
        
        if let box = repository.boxWithId(boxId) {
            let item = Item(itemId: itemId, title: "New Item")
            box.addItem(item)
        }
        
        return itemId //TODO: return NotFound ID
    }
    
    public func changeBoxTitle(boxId: BoxId, title: String) {
        let repository = ServiceLocator.boxRepository()
        
        if let box = repository.boxWithId(boxId) {
            box.title = title
        }
    }
    
    public func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
        let repository = ServiceLocator.boxRepository()
        
        if let box = repository.boxWithId(boxId) {
            if let item = box.item(itemId: itemId) {
                item.title = title
            }
        }
    }
}
