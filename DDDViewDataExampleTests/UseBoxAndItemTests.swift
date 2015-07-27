import Cocoa
import XCTest

import DDDViewDataExample

//class UseBoxAndItemTests: BoxCoreDataTestCase {
//    var boxRepository: BoxRepository?
//    var useCase: ManageBoxesAndItems! = ManageBoxesAndItems()
//    lazy var viewController: ItemViewController = {
//        return self.useCase.itemViewController
//    }()
//
//    override func setUp() {
//        super.setUp()
//        
//        DomainEventPublisher.setSharedInstance(TestDomainEventPublisher())
//        
//        ServiceLocator.resetSharedInstance()
//        ServiceLocator.sharedInstance.setManagedObjectContext(self.context)
//        
//        boxRepository = ServiceLocator.boxRepository()
//    }
//    
//    override func tearDown() {
//        ServiceLocator.resetSharedInstance()
//        DomainEventPublisher.resetSharedInstance()
//        super.tearDown()
//    }
//    
//    func soleBox() -> Box? {
//        return allBoxes().first
//    }
//    
//    func allBoxes() -> [Box] {
//        let request = NSFetchRequest(entityName: Box.entityName)
//        let results: [AnyObject]
//        
//        do {
//            try results = context.executeFetchRequest(request)
//        } catch {
//            XCTFail("fetching all boxes failed")
//            return []
//        }
//        
//        guard let boxes = results as? [Box] else {
//            return []
//        }
//        
//        return boxes
//    }
//    
//    func allItems() -> [Item] {
//        let request = NSFetchRequest(entityName: Item.entityName)
//        let results: [AnyObject]
//
//        do {
//            results = try context.executeFetchRequest(request)
//        } catch _ {
//            XCTFail("fetching all items failed")
//            return []
//        }
//        
//        guard let items = results as? [Item] else {
//            return []
//        }
//        
//        return items
//    }
//    
//    func allBoxNodes() -> [NSTreeNode] {
//        return viewController.itemsController.arrangedObjects.childNodes!!
//    }
//    
//    //MARK: -
//    //MARK: Add Box
//
//    func testAddFirstBox_CreatesBoxRecord() {
//        useCase.showBoxManagementWindow()
//        XCTAssertEqual(boxRepository!.count(), 0, "repo starts empty")
//        
//        // When
//        viewController.addBox(self)
//    
//        // Then
//        XCTAssertEqual(boxRepository!.count(), 1, "stores box record")
//        
//        let box = soleBox()
//        XCTAssert(hasValue(box))
//        if let box = box {
//            XCTAssertEqual(box.title, "New Box")
//        }
//    }
//    
//    func testExistingBoxes_ShowInView() {
//        let existingId = BoxId(678)
//        let existingTitle = "a title"
//        createBoxWithId(existingId, title: existingTitle)
//        
//        useCase.showBoxManagementWindow()
//        
//        let boxNodes = allBoxNodes()
//        XCTAssertEqual(boxNodes.count, 1)
//        let boxNode = boxNodes[0].representedObject as! BoxNode
//        XCTAssertEqual(boxNode.boxId, existingId)
//        XCTAssertEqual(boxNode.title, existingTitle)
//    }
//
//    
//    //MARK: Add Item
//    
//    func testAddItem_WithBoxInRepo_CreatesItemBelowBox() {
//        let existingId = BoxId(1337)
//        createBoxWithId(existingId, title: "irrelevant")
//        useCase.showBoxManagementWindow()
//        
//        // When
//        viewController.addItem(self)
//        
//        // Then
//        let box = soleBox()
//        XCTAssert(hasValue(box))
//        if let box = box {
//            let item = box.managedItems.anyObject() as? Item
//            XCTAssert(hasValue(item))
//            if let item = item {
//                XCTAssertEqual(item.title, "New Item")
//                XCTAssertEqual(item.managedBox, box)
//            }
//        }
//    }
//    
//    func testExistingItems_ShowInView() {
//        let existingBoxId = BoxId(123)
//        let box = createAndFetchBoxWithId(existingBoxId, title: "the box")!
//        let existingItemId = ItemId(456)
//        box.addItemWithId(existingItemId, title: "the item")
//        
//        useCase.showBoxManagementWindow()
//        
//        let boxNodes = allBoxNodes()
//        XCTAssertEqual(boxNodes.count, 1)
//        let boxNode = boxNodes[0].representedObject as! BoxNode
//        XCTAssertEqual(boxNode.children.count, 1)
//        
//        let itemNode = boxNode.children.first as? ItemNode
//        XCTAssert(hasValue(itemNode))
//        if let itemNode = itemNode {
//            XCTAssertEqual(itemNode.itemId, existingItemId)
//        }
//    }
//    
//
//    //MARK: -
//    //MARK: Edit Box
//    
//    func testChangeBoxNodeTitle_PersistsChanges() {
//        let existingId = BoxId(1337)
//        createBoxWithId(existingId, title: "old title")
//        useCase.showBoxManagementWindow()
//        
//        let newTitle = "new title"
//        changeSoleBoxNode(title: newTitle)
//        
//        let box = soleBox()!
//        XCTAssertEqual(box.title, newTitle)
//    }
//    
//    func testChangeBoxNodeTitle_ToEmptyString_ResetsTitle() {
//        let existingId = BoxId(1337)
//        createBoxWithId(existingId, title: "old title")
//        useCase.showBoxManagementWindow()
//        
//        changeSoleBoxNode(title: "")
//        
//        let box = soleBox()!
//        XCTAssertEqual(box.title, BoxNode.defaultTitle)
//    }
//    
//    func changeSoleBoxNode(title newTitle: String) {
//        let soleBoxTreeNode = allBoxNodes().first!
//        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
//        boxNode.title = newTitle
//    }
//    
//    
//    //MARK: Edit Item
//    
//    func testChangeItemNodeTitle_PersistsChanges() {
//        createBoxWithItem()
//        useCase.showBoxManagementWindow()
//        
//        let newTitle = "new title"
//        changeSoleItemNode(title: newTitle)
//        
//        let box = soleBox()!
//        let item = box.managedItems.anyObject()! as! Item
//        XCTAssertEqual(item.title, newTitle)
//    }
//    
//    func createBoxWithItem() {
//        let existingBoxId = BoxId(123)
//        let box = createAndFetchBoxWithId(existingBoxId, title: "the box")!
//        
//        let existingItemId = ItemId(456)
//        box.addItemWithId(existingItemId, title: "old title")
//    }
//    
//    func changeSoleItemNode(title newTitle: String) {
//        let soleBoxTreeNode = allBoxNodes().first!
//        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
//        let itemNode = boxNode.children.first! as! ItemNode
//        itemNode.title = newTitle
//    }
//    
//    
//    //MARK: -
//    //MARK: Remove Box
//    
//    func testRemoveBox_PersistsChanged() {
//        createBoxWithItem()
//        
//        useCase.showBoxManagementWindow()
//        let itemIndexPath = NSIndexPath(index: 0)
//        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
//        
//        // When
//        viewController.removeSelectedObject(self)
//        
//        // Then
//        XCTAssertEqual(allBoxes().count, 0)
//        XCTAssertEqual(allItems().count, 0)
//    }
//    
//    //MARK: Remove Item
//    
//    func testRemoveItem_PersistsChanges() {
//        createBoxWithItem()
//        let box = soleBox()!
//        XCTAssertEqual(box.items.count, 1)
//
//        useCase.showBoxManagementWindow()
//        let itemIndexPath = NSIndexPath(index: 0).indexPathByAddingIndex(0)
//        viewController.itemsController.setSelectionIndexPath(itemIndexPath)
//        
//        // When
//        viewController.removeSelectedObject(self)
//        
//        // Then
//        XCTAssertEqual(box.items.count, 0)
//    }
//}
