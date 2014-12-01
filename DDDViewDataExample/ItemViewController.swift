//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

public protocol HandlesItemListEvents: class {
    func provisionNewBoxId() -> BoxId
    func provisionNewItemId(inBox boxId: BoxId) -> ItemId
}


public struct BoxData {
    let boxId: BoxId
    let title: String
    let itemData: [ItemData]
    
    public init(boxId: BoxId, title: String, itemData: [ItemData]) {
        self.boxId = boxId
        self.title = title
        self.itemData = itemData
    }
}

public struct ItemData {
    let itemId: ItemId
    let title: String
    
    public init(itemId: ItemId, title: String) {
        self.itemId = itemId
        self.title = title
    }
}


@objc(TreeNode)
public protocol TreeNode {
    var title: String { get set }
    var count: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
}

public class BoxNode: NSObject, TreeNode {
    public dynamic var title: String = "New Box"
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf: Bool = false
    public let boxId: BoxId
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(boxData: BoxData) {
        self.boxId = boxData.boxId
        self.title = boxData.title
        super.init()
        
        addItemNodes(boxData.itemData)
    }
    
    func addItemNodes(allItemData: [ItemData]) {
        for itemData in allItemData {
            children.append(ItemNode(itemData: itemData))
        }
    }
}

public class ItemNode: NSObject, TreeNode {
    public dynamic var title: String = "New Item"
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf = true
    public let itemId: ItemId
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(itemData: ItemData) {
        self.itemId = itemData.itemId
        self.title = itemData.title
    }
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
    
    
    //MARK: Populate View
    
    public func displayBoxData(boxData: [BoxData]) {
        itemsController.content = NSMutableArray()
        for data in boxData {
            itemsController.addObject(BoxNode(boxData: data))
        }
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
        if let eventHandler = self.eventHandler {
            addItemNodeToSelectedBox()
            orderTree()
        }
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
        
        if (treeNodeRepresentsBoxNode(firstSelectedTreeNode)) {
            let parentNode = firstSelectedTreeNode.parentNode!
            return parentNode.indexPath
        }
        
        return firstSelectedTreeNode.indexPath
    }
    
    func treeNodeRepresentsBoxNode(treeNode: NSTreeNode) -> Bool {
        return treeNode.leaf
    }
    
    func appendItemNodeToBoxIndexPath(parentIndexPath: NSIndexPath) {
        let parentTreeNode = boxTreeNodeAtIndexPath(parentIndexPath)
        let itemIndexPath = indexPath(appendedToTreeNode: parentTreeNode)
        let item = itemNode(belowBoxTreeNode: parentTreeNode)
        
        itemsController.insertObject(item, atArrangedObjectIndexPath: itemIndexPath)
    }
    
    func indexPath(appendedToTreeNode treeNode: NSTreeNode) -> NSIndexPath {
        let parentIndexPath = treeNode.indexPath
        let childNodeCount = treeNode.childNodes!.count
        return parentIndexPath.indexPathByAddingIndex(childNodeCount)
    }
    
    func itemNode(belowBoxTreeNode boxTreeNode: NSTreeNode)-> ItemNode {
        let boxNode = boxTreeNode.representedObject as BoxNode
        let itemId = eventHandler.provisionNewItemId(inBox: boxNode.boxId)
    
        return ItemNode(itemId: itemId)
    }
    
    func boxTreeNodeAtIndexPath(indexPath: NSIndexPath) -> NSTreeNode {
        assert(indexPath.length == 1, "assumes index path of a box with 1 index only")
        
        let boxNodes: [AnyObject] = itemsController.arrangedObjects.childNodes!!
        let boxIndex = indexPath.indexAtPosition(0)
        let boxNode = boxNodes[boxIndex] as NSTreeNode
        
        return boxNode
    }
}
