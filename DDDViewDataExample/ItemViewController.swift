//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public protocol HandlesItemListEvents: class {
    func provisionNewBoxId() -> BoxId;
    func provisionNewItemId(inBox boxId: BoxId) -> ItemId;
}


@objc(TreeNode)
public protocol TreeNode {
    var title: String { get set }
    var count: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
}

class BoxNode: NSObject, TreeNode {
    dynamic var title: String = "New Box"
    dynamic var count: UInt = 0
    dynamic var children: [TreeNode] = []
    dynamic var isLeaf: Bool = false
    let boxId: BoxId
    
    init(boxId: BoxId) {
        self.boxId = boxId
    }
}

class ItemNode: NSObject, TreeNode {
    dynamic var title: String = "New Item"
    dynamic var count: UInt = 0
    dynamic var children: [TreeNode] = []
    dynamic var isLeaf = true
}


public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

public class ItemViewController: NSViewController, NSOutlineViewDelegate {

    public weak var eventHandler: HandlesItemListEvents!
    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addBoxButton: NSButton!
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
    
    func hasSelection() -> Bool {
        return itemsController.selectedObjects.count > 0
    }

    
    //MARK: Add Boxes
    
    @IBAction public func addBox(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            let boxId = eventHandler.provisionNewBoxId()
            let box = BoxNode(boxId: boxId)
            let indexPath = NSIndexPath(index: nodeCount())
            itemsController.insertObject(box, atArrangedObjectIndexPath: indexPath)
            orderTree()
        }
    }
    
    func orderTree() {
        itemsController.rearrangeObjects()
    }
    
    
    //MARK: Add Items
    
    @IBAction public func addItem(sender: AnyObject) {
        addItemNodeToSelectedBox()
        orderTree()
    }
    
    func addItemNodeToSelectedBox() {
        if let selectionIndexPath = boxIndexPathInSelection() {
            appendItemNodeToBoxIndexPath(selectionIndexPath)
        }
    }
    
    /// The indexPath of the first node if it's a BoxNode.
    func boxIndexPathInSelection() -> NSIndexPath? {
        if (!hasSelection()) {
            return nil
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first! as NSTreeNode
        
        if (firstSelectedTreeNode.leaf) {
            let parentNode = firstSelectedTreeNode.parentNode!
            return parentNode.indexPath
        }
        
        return firstSelectedTreeNode.indexPath
    }
    
    func appendItemNodeToBoxIndexPath(parentIndexPath: NSIndexPath) {
        let item = ItemNode()
        let childNodeCount = childNodeCountAtIndexPath(parentIndexPath)
        let indexPath = parentIndexPath.indexPathByAddingIndex(childNodeCount)
        itemsController.insertObject(item, atArrangedObjectIndexPath: indexPath)
    }
    
    func childNodeCountAtIndexPath(indexPath: NSIndexPath) -> Int {
        let node: NSTreeNode = boxNodeAtIndexPath(indexPath)
        let projectChildNodeCount: Int = node.childNodes!.count
        return projectChildNodeCount
    }
    
    func boxNodeAtIndexPath(indexPath: NSIndexPath) -> NSTreeNode {
        assert(indexPath.length == 1, "assumes index path of a project with 1 index only")
        
        let boxNodes: [AnyObject] = itemsController.arrangedObjects.childNodes!!
        let boxIndex = indexPath.indexAtPosition(0)
        let boxNode = boxNodes[boxIndex] as NSTreeNode
        
        return boxNode
    }
}
