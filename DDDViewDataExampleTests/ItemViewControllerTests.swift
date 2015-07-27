import Cocoa
import XCTest

import DDDViewDataExample
//
//class TestBoxNode: BoxNode {
//    convenience init(title: String, boxId: BoxId) {
//        self.init(boxId: boxId)
//
//        self.title = title
//        count = 1234
//        children = []
//        isLeaf = false
//    }
//    
//    convenience init(title: String) {
//        self.init(title: title, boxId: BoxId(0))
//    }
//    
//    convenience init() {
//        self.init(title: "title")
//    }
//}
//
//
//class EventHandlerStub: HandlesItemListEvents {
//    func createBox() {
//        // no op
//    }
//    
//    func createItem(boxId: BoxId) {
//        // no op
//    }
//    
//    func changeBoxTitle(boxId: BoxId, title: String) {
//        // no op
//    }
//    
//    func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId) {
//        // no op
//    }
//    
//    func removeItem(itemId: ItemId, fromBox boxId: BoxId) {
//        // no op
//    }
//    
//    func removeBox(boxId: BoxId) {
//        // no op
//    }
//}
//
//
//class ItemViewControllerTests: XCTestCase {
//    var viewController: ItemViewController!
//    var testEventHandler: EventHandlerStub! = EventHandlerStub()
//    
//    override func setUp() {
//        super.setUp()
//        
//        let windowController = ItemManagementWindowController()
//        windowController.loadWindow()
//        viewController = windowController.itemViewController
//        viewController.eventHandler = testEventHandler
//    }
//    
//    override func tearDown() {
//        
//        super.tearDown()
//    }
//    
//    func boxNodes() -> [NSTreeNode] {
//        return viewController.itemsController.arrangedObjects.childNodes!!
//    }
//    
//    func boxNodeCount() -> Int {
//        return boxNodes().count
//    }
//    
//    func boxAtIndex(index: Int) -> NSTreeNode {
//        return boxNodes()[index]
//    }
//    
//    func itemTreeNode(atBoxIndex boxIndex: Int, itemIndex: Int) -> NSTreeNode {
//        let boxNode: NSTreeNode = boxAtIndex(boxIndex)
//        return boxNode.childNodes![itemIndex] as NSTreeNode
//    }
//    
//    func boxDataStub() -> BoxData {
//        return BoxData(boxId: BoxId(0), title: "irrelevant", itemData: [])
//    }
//    
//    func itemDataStub() -> ItemData {
//        return itemDataStub(parentBoxId: BoxId(666))
//    }
//    
//    func itemDataStub(parentBoxId boxId: BoxId) -> ItemData {
//        return ItemData(itemId: ItemId(0), title: "irrelevant", boxId: boxId)
//    }
//    
//    //MARK: Nib Setup
//    
//    func testView_IsLoaded() {
//        XCTAssertNotNil(viewController.view, "view should be set in Nib")
//        XCTAssertEqual(viewController.view.className, "NSOutlineView", "view should be outline view")
//        XCTAssertEqual(viewController.view, viewController.outlineView, "tableView should be alternative to view")
//    }
//
//    func testOutlineViewColumns_NamedProperly() {
//        let outlineView = viewController.outlineView
//        
//        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameTitle), "outline should include title column")
//        XCTAssertNotNil(outlineView.tableColumnWithIdentifier(kColumnNameCount), "outline should include count column")
//    }
//    
//    func testItemsController_IsConnected() {
//        XCTAssertNotNil(viewController.itemsController)
//    }
//    
//    func testItemsController_PreservesSelection() {
//        XCTAssertTrue(viewController.itemsController.preservesSelection)
//    }
//    
//    func testItemsController_CocoaBindings() {
//        let controller = viewController.itemsController
//        let outlineView = viewController.outlineView
//        let titleColumn = outlineView.tableColumnWithIdentifier(kColumnNameTitle)
//        let countColumn = outlineView.tableColumnWithIdentifier(kColumnNameCount)
//        
//        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"))
//        XCTAssertTrue(hasBinding(outlineView, binding: NSContentBinding, to: controller, throughKeyPath: "arrangedObjects"))
//        
//        XCTAssertTrue(hasBinding(titleColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.title"))
//        XCTAssertTrue(hasBinding(countColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.count"))
//    }
//    
//    func testAddBoxButton_IsConnected() {
//        XCTAssertNotNil(viewController.addBoxButton)
//    }
//    
//    func testAddBoxButton_IsWiredToAction() {
//        XCTAssertEqual(viewController.addBoxButton.action, Selector("addBox:"))
//    }
//    
//    func testAddItemButton_IsConnected() {
//        XCTAssertNotNil(viewController.addItemButton)
//    }
//    
//    func testAddItemButton_IsWiredToAction() {
//        XCTAssertEqual(viewController.addItemButton.action, Selector("addItem:"))
//    }
//    
//    func testAddItemButton_CocoaBindings() {
//        XCTAssertTrue(hasBinding(viewController.addItemButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
//    }
//    
//    func testRemoveButton_IsConnected() {
//        XCTAssertNotNil(viewController.removeButton)
//    }
//
//    func testRemoveButton_IsWiredToAction() {
//        XCTAssertEqual(viewController.removeButton.action, Selector("removeSelectedObject:"))
//    }
//    
//    func testRemoveButton_CocoaBindings() {
//        XCTAssertTrue(hasBinding(viewController.removeButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
//    }
//    
//    func testItemRowView_TitleCell_SetUpProperly() {
//        viewController.itemsController.addObject(TestBoxNode())
//        
//        let titleCellView: NSTableCellView = viewController.outlineView.viewAtColumn(0, row: 0, makeIfNecessary: true) as! NSTableCellView
//        let titleTextField = titleCellView.textField!
//        XCTAssertTrue(titleTextField.editable)
//        XCTAssertTrue(hasBinding(titleTextField, binding: NSValueBinding, to: titleCellView, throughKeyPath: "objectValue.title", transformingWith: "NonNilStringValueTransformer"))
//    }
//    
//    func testItemRowView_CountCell_SetUpProperly() {
//        viewController.itemsController.addObject(TestBoxNode())
//        
//        let countCellView: NSTableCellView = viewController.outlineView.viewAtColumn(1, row: 0, makeIfNecessary: true) as! NSTableCellView
//        let countTextField = countCellView.textField!
//        XCTAssertFalse(countTextField.editable, "count text field should not be editable")
//        XCTAssertTrue(hasBinding(countTextField, binding: NSValueBinding, to: countCellView, throughKeyPath: "objectValue.count"))
//    }
//    
//    
//    //MARK: - 
//    //MARK: Adding Boxes
//
//    func testInitially_TreeIsEmpty() {
//        XCTAssertEqual(boxNodeCount(), 0, "start with empty tree")
//    }
//    
//    func testInitially_AddItemButtonIsDisabled() {
//        XCTAssertFalse(viewController.addItemButton.enabled, "disable item button without boxes")
//    }
//    
//    func testConsumeBox_WithEmptyList_AddsNode() {
//        viewController.consume(boxDataStub())
//        
//        XCTAssertEqual(boxNodeCount(), 1, "adds item to tree")
//    }
//    
//    func testConsumeBox_WithEmptyList_EnablesAddItemButton() {
//        viewController.consume(boxDataStub())
//        
//        XCTAssertTrue(viewController.addItemButton.enabled, "enable item button by adding boxes")
//    }
//    
//    func testConsumeBox_WithExistingBox_OrdersThemByTitle() {
//        // Given
//        let bottomItem = TestBoxNode(title: "ZZZ Should be at the bottom")
//        viewController.itemsController.addObject(bottomItem)
//        
//        let existingNode: NSObject = boxAtIndex(0)
//        
//        // When
//        viewController.consume(boxDataStub())
//        
//        // Then
//        XCTAssertEqual(boxNodeCount(), 2, "add node to existing one")
//        let lastNode: NSObject = boxAtIndex(1)
//        XCTAssertEqual(existingNode, lastNode, "new node should be put before existing one")
//    }
//
//    func testAddBox_Twice_SelectsSecondBox() {
//        let treeController = viewController.itemsController
//        treeController.addObject(TestBoxNode(title: "first"))
//        treeController.addObject(TestBoxNode(title: "second"))
//        
//        XCTAssertTrue(treeController.selectedNodes.count > 0, "should auto-select")
//        let selectedNode: NSTreeNode = treeController.selectedNodes[0]
//        let item: TreeNode = selectedNode.representedObject as! TreeNode
//        XCTAssertEqual(item.title, "second", "select latest insertion")
//    }
//    
//    
//    //MARK: Adding Items
//    
//    func testConsumeItem_WithoutBoxes_DoesNothing() {
//        viewController.consume(itemDataStub())
//        
//        XCTAssertEqual(boxNodeCount(), 0, "don't add boxes or anything")
//    }
//    
//    func testConsumeItem_WithSelectedBox_InsertsItemBelowSelectedBox() {
//        // Pre-populate
//        let treeController = viewController.itemsController
//        treeController.addObject(TestBoxNode(title: "first", boxId: BoxId(1)))
//        treeController.addObject(TestBoxNode(title: "second", boxId: BoxId(2)))
//        
//        // Select first node
//        let selectionIndexPath = NSIndexPath(index: 0)
//        treeController.setSelectionIndexPath(selectionIndexPath)
//        let selectedBox = treeController.selectedNodes[0].representedObject as! TreeNode
//        XCTAssertEqual(selectedBox.children.count, 0, "box starts empty")
//        
//        viewController.consume(itemDataStub(parentBoxId: BoxId(1)))
//        
//        // Then
//        if selectedBox.children.count > 0 {
//            XCTAssert(selectedBox.children[0].isLeaf)
//        } else {
//            XCTFail("box contains no child")
//        }
//    }
//    
//    
//    //MARK: Displaying Box Data
//    
//    func testDisplayData_Once_PopulatesTree() {
//        let itemId = ItemId(444)
//        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
//        let boxId = BoxId(1122)
//        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])
//
//        viewController.displayBoxData([boxData])
//        
//        XCTAssertEqual(boxNodeCount(), 1)
//        let soleBoxTreeNode = boxAtIndex(0)
//        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
//        XCTAssertEqual(boxNode.boxId, boxId)
//        
//        let itemNodes = soleBoxTreeNode.childNodes! as [NSTreeNode]
//        XCTAssertEqual(itemNodes.count, 1)
//        if let soleItemTreeNode = itemNodes.first {
//            let itemNode = soleItemTreeNode.representedObject as! ItemNode
//            XCTAssertEqual(itemNode.itemId, itemId)
//        }
//    }
//    
//    func testDisplayData_Twice_ReplacedNodes() {
//        let itemId = ItemId(444)
//        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
//        let boxId = BoxId(1122)
//        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])
//        
//        viewController.displayBoxData([boxData])
//        viewController.displayBoxData([boxData])
//        
//        XCTAssertEqual(boxNodeCount(), 1)
//        XCTAssertEqual(boxAtIndex(0).childNodes!.count, 1)
//    }
//
//    
//    //MARK: -
//    //MARK: Removing Boxes
//    
//    func testRemoveBox_RemovesNodeFromTree() {
//        let treeController = viewController.itemsController
//        treeController.addObject(TestBoxNode(title: "the box"))
//        treeController.setSelectionIndexPath(NSIndexPath(index: 0))
//        XCTAssertEqual(boxNodeCount(), 1)
//        
//        viewController.removeSelectedObject(self)
//        
//        XCTAssertEqual(boxNodeCount(), 0)
//    }
//    
//    func testRemoveItem_RemovesNodeFromTree() {
//        let treeController = viewController.itemsController
//        let rootNode = TestBoxNode(title: "the box")
//        rootNode.children = [TestBoxNode(title: "the item")]
//        treeController.addObject(rootNode)
//        treeController.setSelectionIndexPath(NSIndexPath(index: 0).indexPathByAddingIndex(0))
//        XCTAssertEqual(boxNodes().first!.childNodes!.count, 1)
//        
//        viewController.removeSelectedObject(self)
//        
//        XCTAssertEqual(boxNodeCount(), 1)
//        XCTAssertEqual(boxNodes().first!.childNodes!.count, 0)
//    }
//
//}
