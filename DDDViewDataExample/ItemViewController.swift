//
//  ItemViewController.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 17.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

@objc(TreeNode)
public protocol TreeNode {
    var title: String { get set }
    var count: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    weak var eventHandler: HandlesItemListChanges? { get }
    func resetTitleToDefaultTitle()
}

@objc(HandlesItemListChanges)
public protocol HandlesItemListChanges: class {
    func treeNodeDidChange(treeNode: TreeNode, title: String)
}

@objc(NonNilStringValueTransformer)
public class NonNilStringValueTransformer: NSValueTransformer {
    override public func transformedValue(value: AnyObject?) -> AnyObject? {
        if value == nil {
            return ""
        }
        
        return value
    }
}

public class BoxNode: NSObject, TreeNode {
    public class var defaultTitle: String! { return "Box" }
    public dynamic var title: String = BoxNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf: Bool = false
    public let boxId: BoxId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(boxData: BoxData) {
        self.boxId = boxData.boxId
        self.title = boxData.title
        super.init()
    }
    
    public func addItemNode(itemNode: ItemNode) {
        children.append(itemNode)
    }
    
    public func resetTitleToDefaultTitle() {
        self.title = BoxNode.defaultTitle
    }
}

public class ItemNode: NSObject, TreeNode {
    public class var defaultTitle: String! { return "Item" }
    public dynamic var title: String = ItemNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    public dynamic var count: UInt = 0
    public dynamic var children: [TreeNode] = []
    public dynamic var isLeaf = true
    public let itemId: ItemId
    public weak var eventHandler: HandlesItemListChanges?
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(itemData: ItemData) {
        self.itemId = itemData.itemId
        self.title = itemData.title
    }
    
    public func parentBoxNode(inArray nodes: [BoxNode]) -> BoxNode? {
        for boxNode in nodes {
            if contains(boxNode.children as [ItemNode], self) {
                return boxNode
            }
        }
        
        return nil
    }
    
    public func resetTitleToDefaultTitle() {
        self.title = ItemNode.defaultTitle
    }
}


public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

public class ItemViewController: NSViewController, NSOutlineViewDelegate, HandlesItemListChanges, ConsumesBoxAndItem {

    public weak var eventHandler: HandlesItemListEvents!
    @IBOutlet public weak var itemsController: NSTreeController!
    @IBOutlet public weak var addBoxButton: NSButton!
    @IBOutlet public weak var addItemButton: NSButton!
    @IBOutlet public weak var removeButton: NSButton!
    
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
        removeExistingNodes()
        for data in boxData {
            itemsController.addObject(boxNode(data))
        }
    }

    func removeExistingNodes() {
        itemsController.content = NSMutableArray()
    }
    
    func boxNode(boxData: BoxData) -> BoxNode {
        let boxNode = BoxNode(boxData: boxData)
        // TODO test the title setup
//        boxNode.title = boxData.title
        boxNode.eventHandler = self
        boxNode.children = itemNodes(boxData.itemData)
        
        return boxNode
    }
    
    func itemNodes(allItemData: [ItemData]) -> [ItemNode] {
        var result: [ItemNode] = allItemData.map() { (itemData: ItemData) -> ItemNode in
            self.itemNode(itemData)
        }
        return result
    }
    
    func itemNode(itemData: ItemData) -> ItemNode {
        let itemNode = ItemNode(itemData: itemData)
        // TODO test the title setup
//        itemNode.title = itemData.title
        itemNode.eventHandler = self
        
        return itemNode
    }

    
    //MARK: Add Boxes
    
    @IBAction public func addBox(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            eventHandler.createBox()
        }
    }
    
    public func consume(boxData: BoxData) {
        let boxNode = self.boxNode(boxData)
        let indexPath = NSIndexPath(index: nodeCount())
        itemsController.insertObject(boxNode, atArrangedObjectIndexPath: indexPath)
        orderTree()
        
        delay(3, { () -> () in
            boxNode.title = "TEST!!"
        })
    }
    
    func orderTree() {
        itemsController.rearrangeObjects()
    }
    
    
    //MARK: Add Items
    
    @IBAction public func addItem(sender: AnyObject) {
        if let eventHandler = self.eventHandler {
            addItemNodeToSelectedBox()
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
        let boxNode = parentTreeNode.representedObject as BoxNode
        eventHandler.createItem(boxNode.boxId)
    }
    
    func boxTreeNodeAtIndexPath(indexPath: NSIndexPath) -> NSTreeNode {
        assert(indexPath.length == 1, "assumes index path of a box with 1 index only")
        
        let boxNodes: [AnyObject] = itemsController.arrangedObjects.childNodes!!
        let boxIndex = indexPath.indexAtPosition(0)
        let boxNode = boxNodes[boxIndex] as NSTreeNode
        
        return boxNode
    }
    
    public func consume(itemData: ItemData) {
        if let boxId = itemData.boxId {
            if let boxNode = existingBoxNode(boxId) {
                let itemId = itemData.itemId
                let itemNode = self.itemNode(itemData)
                
                boxNode.addItemNode(itemNode)
                orderTree()
            }
        }
    }
    
    func existingBoxNode(boxId: BoxId) -> BoxNode? {
        let boxNodes = itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
        for treeNode in boxNodes {
            let boxNode = treeNode.representedObject as BoxNode
            if boxNode.boxId == boxId {
                return boxNode
            }
        }
        return nil
    }
    
    
    //MARK: Change items
    
    public func treeNodeDidChange(treeNode: TreeNode, title: String) {
        if title.isEmpty {
            changeNodeTitleToPlaceholderValue(treeNode)
        } else {
            broadcastTitleChange(treeNode)
            orderTree()
        }
    }
    
    func changeNodeTitleToPlaceholderValue(treeNode: TreeNode) {
        treeNode.resetTitleToDefaultTitle()
    }
    
    func broadcastTitleChange(treeNode: TreeNode) {
        if let boxNode = treeNode as? BoxNode {
            eventHandler.changeBoxTitle(boxNode.boxId, title: boxNode.title)
        } else if let itemNode = treeNode as? ItemNode {
            if let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                eventHandler.changeItemTitle(itemNode.itemId, title: itemNode.title, inBox: boxNode.boxId)
            }
        }
    }
    
    /// Returns all of `itemsController` root-level nodes' represented objects
    func boxNodes() -> [BoxNode] {
        let rootNodes = itemsController.arrangedObjects.childNodes!! as [NSTreeNode]
        return rootNodes.map { (treeNode: NSTreeNode) -> BoxNode in
            return treeNode.representedObject as BoxNode
        }
    }
    
    
    //MARK: Remove items
    
    @IBAction public func removeSelectedObject(sender: AnyObject) {
        if (!hasSelection()) {
            return
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first! as NSTreeNode
        let indexPath = firstSelectedTreeNode.indexPath
        let treeNode: TreeNode = firstSelectedTreeNode.representedObject as TreeNode

        if let boxNode = treeNode as? BoxNode {
            eventHandler.removeBox(boxNode.boxId)
        } else if let itemNode = treeNode as? ItemNode {
            if let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                eventHandler.removeItem(itemNode.itemId, fromBox: boxNode.boxId)
            }
        }
        
        itemsController.removeObjectAtArrangedObjectIndexPath(indexPath)
    }
}
