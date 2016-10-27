import Cocoa
import XCTest

@testable import DDDViewDataExample

class UseBoxAndItemTests: CoreDataTestCase {
    var boxRepository: BoxRepository?
    var useCase: ManageBoxesAndItems! = ManageBoxesAndItems()
    lazy var viewController: ItemViewController = {
        return self.useCase.itemViewController
    }()

    override func setUp() {
        super.setUp()
        
        DomainEventPublisher.sharedInstance = TestDomainEventPublisher()
        
        ServiceLocator.resetSharedInstance()
        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
        
        boxRepository = ServiceLocator.boxRepository()
    }
    
    override func tearDown() {
        ServiceLocator.resetSharedInstance()
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }
    
    func soleBox() -> ManagedBox? {
        return allBoxes().first
    }
    
    func allBoxes() -> [ManagedBox] {
        let request = NSFetchRequest<ManagedBox>(entityName: ManagedBox.entityName)
        let results: [AnyObject]
        
        do {
            try results = context.fetch(request)
        } catch {
            XCTFail("fetching all boxes failed")
            return []
        }
        
        guard let boxes = results as? [ManagedBox] else {
            return []
        }
        
        return boxes
    }
    
    func allItems() -> [ManagedItem] {
        let request = NSFetchRequest<ManagedItem>(entityName: ManagedItem.entityName)
        let results: [AnyObject]

        do {
            results = try context.fetch(request)
        } catch _ {
            XCTFail("fetching all items failed")
            return []
        }
        
        guard let items = results as? [ManagedItem] else {
            return []
        }
        
        return items
    }
    
    func allBoxNodes() -> [NSTreeNode] {
        return (viewController.itemsController.arrangedObjects as AnyObject).children!!
    }
    
    //MARK: -
    //MARK: Add Box

    func testAddFirstBox_CreatesBoxRecord() {
        useCase.showBoxManagementWindow()
        XCTAssertEqual(boxRepository!.count(), 0, "repo starts empty")
        
        // When
        viewController.addBox(self)
    
        // Then
        XCTAssertEqual(boxRepository!.count(), 1, "stores box record")
        
        let box = soleBox()
        XCTAssert(hasValue(box))
        if let box = box {
            XCTAssertEqual(box.title, "New Box")
        }
    }
    
    func testExistingBoxes_ShowInView() {
        let existingId = BoxId(678)
        let existingTitle = "a title"
        ManagedBox.insertManagedBox(existingId, title: existingTitle, inManagedObjectContext: context)
        
        useCase.showBoxManagementWindow()
        
        let boxNodes = allBoxNodes()
        XCTAssertEqual(boxNodes.count, 1)
        let boxNode = boxNodes[0].representedObject as! BoxNode
        XCTAssertEqual(boxNode.boxId, existingId)
        XCTAssertEqual(boxNode.title, existingTitle)
    }

    
    //MARK: Add Item
    
    func testAddItem_WithBoxInRepo_CreatesItemBelowBox() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "irrelevant", inManagedObjectContext: context)
        useCase.showBoxManagementWindow()
        
        // When
        viewController.addItem(self)
        
        // Then
        let managedBox = soleBox()
        XCTAssert(hasValue(managedBox))
        if let managedBox = managedBox {
            let managedItem = managedBox.items.anyObject() as? ManagedItem
            XCTAssert(hasValue(managedItem))
            if let managedItem = managedItem {
                XCTAssertEqual(managedItem.title, "New Item")
                XCTAssertEqual(managedItem.box, managedBox)
            }
        }
    }
    
    func testExistingItems_ShowInView() {
        let existingBoxId = BoxId(123)
        ManagedBox.insertManagedBox(existingBoxId, title: "the box", inManagedObjectContext: context)
        let managedBox = soleBox()!
        let existingItemId = ItemId(456)
        let existingItem = Item(itemId: existingItemId, title: "the item")
        ManagedItem.insertManagedItem(existingItem, managedBox: managedBox, inManagedObjectContext: context)
        
        useCase.showBoxManagementWindow()
        
        let boxNodes = allBoxNodes()
        XCTAssertEqual(boxNodes.count, 1)
        let boxNode = boxNodes[0].representedObject as! BoxNode
        XCTAssertEqual(boxNode.children.count, 1)
        
        let itemNode = boxNode.children.first as? ItemNode
        XCTAssert(hasValue(itemNode))
        if let itemNode = itemNode {
            XCTAssertEqual(itemNode.itemId, existingItemId)
        }
    }
    

    //MARK: -
    //MARK: Edit Box
    
    func testChangeBoxNodeTitle_PersistsChanges() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "old title", inManagedObjectContext: context)
        useCase.showBoxManagementWindow()
        
        let newTitle = "new title"
        changeSoleBoxNode(title: newTitle)
        
        let managedBox = soleBox()!
        XCTAssertEqual(managedBox.title, newTitle)
    }
    
    func testChangeBoxNodeTitle_ToEmptyString_ResetsTitle() {
        let existingId = BoxId(1337)
        ManagedBox.insertManagedBox(existingId, title: "old title", inManagedObjectContext: context)
        useCase.showBoxManagementWindow()
        
        changeSoleBoxNode(title: "")
        
        let managedBox = soleBox()!
        XCTAssertEqual(managedBox.title, BoxNode.defaultTitle)
    }
    
    func changeSoleBoxNode(title newTitle: String) {
        let soleBoxTreeNode = allBoxNodes().first!
        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
        boxNode.title = newTitle
    }
    
    
    //MARK: Edit Item
    
    func testChangeItemNodeTitle_PersistsChanges() {
        createBoxWithItem()
        useCase.showBoxManagementWindow()
        
        let newTitle = "new title"
        changeSoleItemNode(title: newTitle)
        
        let managedBox = soleBox()!
        let managedItem = managedBox.items.anyObject()! as! ManagedItem
        XCTAssertEqual(managedItem.title, newTitle)
    }
    
    func createBoxWithItem() {
        let existingBoxId = BoxId(123)
        ManagedBox.insertManagedBox(existingBoxId, title: "the box", inManagedObjectContext: context)
        
        let managedBox = soleBox()!
        let existingItemId = ItemId(456)
        let existingItem = Item(itemId: existingItemId, title: "old title")
        ManagedItem.insertManagedItem(existingItem, managedBox: managedBox, inManagedObjectContext: context)
    }
    
    func changeSoleItemNode(title newTitle: String) {
        let soleBoxTreeNode = allBoxNodes().first!
        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
        let itemNode = boxNode.children.first! as! ItemNode
        itemNode.title = newTitle
    }
    
    
    //MARK: -
    //MARK: Remove Box
    
    func testRemoveBox_PersistsChanged() {
        createBoxWithItem()
        
        useCase.showBoxManagementWindow()
        let itemIndexPath = IndexPath(index: 0)
        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
        
        // When
        viewController.removeSelectedObject(self)
        
        // Then
        XCTAssertEqual(allBoxes().count, 0)
        XCTAssertEqual(allItems().count, 0)
    }
    
    //MARK: Remove Item
    
    func testRemoveItem_PersistsChanges() {
        createBoxWithItem()
        let managedBox = soleBox()!
        XCTAssertEqual(managedBox.items.count, 1)

        useCase.showBoxManagementWindow()
        let itemIndexPath = IndexPath(arrayLiteral: 0, 0)
        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
        
        // When
        viewController.removeSelectedObject(self)
        
        // Then
        XCTAssertEqual(managedBox.items.count, 0)
    }
}
