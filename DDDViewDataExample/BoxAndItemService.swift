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
        //FIXME: this is a stub
        return ItemId(0)
    }
}
