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
    func treeNodeDidChange(_ treeNode: TreeNode, title: String)
}

@objc(NonNilStringValueTransformer)
open class NonNilStringValueTransformer: ValueTransformer {
    override open func transformedValue(_ value: Any?) -> Any? {
        guard let value = value else {
            return ""
        }
        
        return value
    }
}

open class BoxNode: NSObject, TreeNode {
    open class var defaultTitle: String! { return "Box" }
    open dynamic var title: String = BoxNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    open dynamic var count: UInt = 0
    open dynamic var children: [TreeNode] = []
    open dynamic var isLeaf: Bool = false
    open let boxId: BoxId
    open weak var eventHandler: HandlesItemListChanges?
    
    public init(boxId: BoxId) {
        self.boxId = boxId
    }
    
    public init(boxData: BoxData) {
        self.boxId = boxData.boxId
        self.title = boxData.title
        super.init()
    }
    
    open func addItemNode(_ itemNode: ItemNode) {
        children.append(itemNode)
    }
    
    open func resetTitleToDefaultTitle() {
        self.title = BoxNode.defaultTitle
    }
}

open class ItemNode: NSObject, TreeNode {
    open class var defaultTitle: String! { return "Item" }
    open dynamic var title: String = ItemNode.defaultTitle {
        didSet {
            if let controller = self.eventHandler {
                controller.treeNodeDidChange(self, title: title)
            }
        }
    }
    open dynamic var count: UInt = 0
    open dynamic var children: [TreeNode] = []
    open dynamic var isLeaf = true
    open let itemId: ItemId
    open weak var eventHandler: HandlesItemListChanges?
    
    public init(itemId: ItemId) {
        self.itemId = itemId
    }
    
    public init(itemData: ItemData) {
        self.itemId = itemData.itemId
        self.title = itemData.title
    }
    
    open func parentBoxNode(inArray nodes: [BoxNode]) -> BoxNode? {
        for boxNode in nodes {
            if (boxNode.children as! [ItemNode]).contains(self) {
                return boxNode
            }
        }
        
        return nil
    }
    
    open func resetTitleToDefaultTitle() {
        self.title = ItemNode.defaultTitle
    }
}


public let kColumnNameTitle = "Title"
public let kColumnNameCount = "Count"

open class ItemViewController: NSViewController, NSOutlineViewDelegate, HandlesItemListChanges, ConsumesBoxAndItem {

    open weak var eventHandler: HandlesItemListEvents!
    @IBOutlet open weak var itemsController: NSTreeController!
    @IBOutlet open weak var addBoxButton: NSButton!
    @IBOutlet open weak var addItemButton: NSButton!
    @IBOutlet open weak var removeButton: NSButton!
    
    open var outlineView: NSOutlineView {
        return self.view as! NSOutlineView
    }
    
    var itemsSortDescriptors: [NSSortDescriptor] {
        let sortByTitle = NSSortDescriptor(key: "title", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        
        return [sortByTitle]
    }
    
    func nodeCount() -> Int {
        return (itemsController.arrangedObjects as AnyObject).children!.count
    }
    
    func hasSelection() -> Bool {
        return itemsController.selectedObjects.count > 0
    }
    
    
    //MARK: Populate View
    
    open func displayBoxData(_ boxData: [BoxData]) {
        removeExistingNodes()
        for data in boxData {
            itemsController.addObject(boxNode(data))
        }
    }

    func removeExistingNodes() {
        itemsController.content = NSMutableArray()
    }
    
    func boxNode(_ boxData: BoxData) -> BoxNode {
        let boxNode = BoxNode(boxData: boxData)
        // TODO test the title setup
//        boxNode.title = boxData.title
        boxNode.eventHandler = self
        boxNode.children = itemNodes(boxData.itemData)
        
        return boxNode
    }
    
    func itemNodes(_ allItemData: [ItemData]) -> [ItemNode] {
        let result: [ItemNode] = allItemData.map() { (itemData: ItemData) -> ItemNode in
            self.itemNode(itemData)
        }
        return result
    }
    
    func itemNode(_ itemData: ItemData) -> ItemNode {
        let itemNode = ItemNode(itemData: itemData)
        // TODO test the title setup
//        itemNode.title = itemData.title
        itemNode.eventHandler = self
        
        return itemNode
    }

    
    //MARK: Add Boxes
    
    @IBAction open func addBox(_ sender: AnyObject) {
        guard let eventHandler = self.eventHandler else {
            return
        }
        
        eventHandler.createBox()
    }
    
    open func consume(_ boxData: BoxData) {
        let boxNode = self.boxNode(boxData)
        let indexPath = IndexPath(index: nodeCount())
        itemsController.insert(boxNode, atArrangedObjectIndexPath: indexPath)
        orderTree()
    }
    
    func orderTree() {
        itemsController.rearrangeObjects()
    }
    
    
    //MARK: Add Items
    
    @IBAction open func addItem(_ sender: AnyObject) {
        addItemNodeToSelectedBox()
    }
    
    func addItemNodeToSelectedBox() {
        guard let selectionIndexPath = boxIndexPathInSelection() else {
            return
        }
        
        appendItemNodeToBoxIndexPath(selectionIndexPath)
    }
    
    /// The indexPath of the first node if it's a BoxNode.
    func boxIndexPathInSelection() -> IndexPath? {
        if (!hasSelection()) {
            return nil
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first!
        
        if (treeNodeRepresentsBoxNode(firstSelectedTreeNode)) {
            let parentNode = firstSelectedTreeNode.parent!
            return parentNode.indexPath
        }
        
        return firstSelectedTreeNode.indexPath
    }
    
    func treeNodeRepresentsBoxNode(_ treeNode: NSTreeNode) -> Bool {
        return treeNode.isLeaf
    }
    
    func appendItemNodeToBoxIndexPath(_ parentIndexPath: IndexPath) {
        guard let eventHandler = eventHandler else {
            return
        }
        
        let parentTreeNode = boxTreeNodeAtIndexPath(parentIndexPath)
        let boxNode = parentTreeNode.representedObject as! BoxNode
        eventHandler.createItem(boxNode.boxId)
    }
    
    func boxTreeNodeAtIndexPath(_ indexPath: IndexPath) -> NSTreeNode {
        guard let boxIndex = indexPath.first,
            indexPath.count == 1
            else { preconditionFailure("assumes index path of a box with 1 index only") }

        let boxNodes = (itemsController.arrangedObjects as AnyObject).children!
        let boxNode = boxNodes[boxIndex] as! NSTreeNode
        
        return boxNode
    }
    
    open func consume(_ itemData: ItemData) {
        guard let boxId = itemData.boxId, let boxNode = existingBoxNode(boxId) else {
            return
        }

        let itemNode = self.itemNode(itemData)
        
        boxNode.addItemNode(itemNode)
        orderTree()
    }
    
    func existingBoxNode(_ boxId: BoxId) -> BoxNode? {
        let boxNodes = (itemsController.arrangedObjects as AnyObject).children!.map { $0 as! NSTreeNode }
        for treeNode in boxNodes {
            let boxNode = treeNode.representedObject as! BoxNode
            if boxNode.boxId == boxId {
                return boxNode
            }
        }
        return nil
    }
    
    
    //MARK: Change items
    
    open func treeNodeDidChange(_ treeNode: TreeNode, title: String) {
        if title.isEmpty {
            changeNodeTitleToPlaceholderValue(treeNode)
        } else {
            broadcastTitleChange(treeNode)
            orderTree()
        }
    }
    
    func changeNodeTitleToPlaceholderValue(_ treeNode: TreeNode) {
        treeNode.resetTitleToDefaultTitle()
    }
    
    func broadcastTitleChange(_ treeNode: TreeNode) {
        if let boxNode = treeNode as? BoxNode {
            eventHandler.changeBoxTitle(boxNode.boxId, title: boxNode.title)
        } else if let itemNode = treeNode as? ItemNode,
            let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
                
            eventHandler.changeItemTitle(itemNode.itemId, title: itemNode.title, inBox: boxNode.boxId)
        }
    }
    
    /// Returns all of `itemsController` root-level nodes' represented objects
    func boxNodes() -> [BoxNode] {
        let rootNodes = (itemsController.arrangedObjects as AnyObject).children!.map { $0 as! NSTreeNode }
        return rootNodes.map { (treeNode: NSTreeNode) -> BoxNode in
            return treeNode.representedObject as! BoxNode
        }
    }
    
    
    //MARK: Remove items
    
    @IBAction open func removeSelectedObject(_ sender: AnyObject) {
        if (!hasSelection()) {
            return
        }
        
        let firstSelectedTreeNode: NSTreeNode = itemsController.selectedNodes.first! as NSTreeNode
        let indexPath = firstSelectedTreeNode.indexPath
        let treeNode: TreeNode = firstSelectedTreeNode.representedObject as! TreeNode

        if let boxNode = treeNode as? BoxNode {
            eventHandler.removeBox(boxNode.boxId)
        } else if let itemNode = treeNode as? ItemNode,
            let boxNode = itemNode.parentBoxNode(inArray: boxNodes()) {
            
            eventHandler.removeItem(itemNode.itemId, fromBox: boxNode.boxId)
        }
        
        itemsController.removeObject(atArrangedObjectIndexPath: indexPath)
    }
}
