//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

class ItemNode: NSObject {
    dynamic var title: String = "New Item"
    dynamic var count: UInt = 0
    dynamic var children: [ItemNode] = []
    dynamic var isLeaf: Bool = false
    
}

public let kTitleColumnName = "Title"
public let kCountColumnName = "Count"

public class ItemViewController: NSViewController, NSOutlineViewDelegate {

    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addItemButton: NSButton!
    
    public var outlineView: NSOutlineView {
        return self.view as NSOutlineView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: "caseInsensitiveCompare:")
        
        return [sortByTitle]
    }
    
    func nodeCount() -> Int {
        return itemsController.arrangedObjects.childNodes!!.count
    }
    
    @IBAction public func addItem(sender: AnyObject) {
        let item = ItemNode()
        item.children.append(ItemNode())
        let indexPath = NSIndexPath(index: nodeCount())
        itemsController.insertObject(item, atArrangedObjectIndexPath: indexPath)
        itemsController.rearrangeObjects() // TODO item loses focus
    }
}
