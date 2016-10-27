import Cocoa

@objc public protocol TreeNode {
    var title: String { get set }
    var count: UInt { get set }
    var children: [TreeNode] { get }
    var isLeaf: Bool { get }
    weak var eventHandler: HandlesItemListChanges? { get }
    func resetTitleToDefaultTitle()
}

open class BoxNode: NSObject, TreeNode {
    open static var defaultTitle: String! { return "Box" }
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
    open static var defaultTitle: String! { return "Item" }
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
