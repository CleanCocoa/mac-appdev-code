//
//  ManageBoxesAndItems.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 28.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public class ManageBoxesAndItems {
    lazy var windowController: ItemManagementWindowController = {
        let controller = ItemManagementWindowController()
        controller.loadWindow()
        return controller
    }()
    
    lazy var boxAndItemService = BoxAndItemService()
    
    public init() { }
    
    public lazy var itemViewController: ItemViewController = {
        return self.windowController.itemViewController
    }()
    
    public func showBoxManagementWindow() {
        let repository = ServiceLocator.boxRepository()
        let allBoxes = repository.boxes()
        let allBoxData = boxData(allBoxes)
        
        windowController.displayBoxData(allBoxData)
        windowController.eventHandler = boxAndItemService
        
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
    
    func boxData(boxes: [Box]) -> [BoxData] {
        var allBoxData: [BoxData] = []
        
        for box in boxes {
            var allItemData: [ItemData] = []
            
            for item in box.items {
                let itemData = ItemData(itemId: item.itemId, title: item.title)
                allItemData.append(itemData)
            }
            
            let boxData = BoxData(boxId: box.boxId, title: box.title, itemData: allItemData)
            allBoxData.append(boxData)
        }
        
        return allBoxData
    }
}
