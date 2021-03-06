import Cocoa
import XCTest

@testable import DDDViewDataExample

class TestBoxNode: BoxNode {
    convenience init(title: String, boxId: BoxId) {
        self.init(boxId: boxId)

        self.title = title
        count = 1234
        children = []
        isLeaf = false
    }
    
    convenience init(title: String) {
        self.init(title: title, boxId: BoxId(0))
    }
    
    convenience init() {
        self.init(title: "title")
    }
}


class EventHandlerStub: HandlesItemListEvents {
    func createBox() {
        // no op
    }
    
    func createItem(_ boxId: BoxId) {
        // no op
    }
    
    func changeBoxTitle(_ boxId: BoxId, title: String) {
        // no op
    }
    
    func changeItemTitle(_ itemId: ItemId, title: String, inBox boxId: BoxId) {
        // no op
    }
    
    func removeItem(_ itemId: ItemId, fromBox boxId: BoxId) {
        // no op
    }
    
    func removeBox(_ boxId: BoxId) {
        // no op
    }
}


class ItemViewControllerTests: XCTestCase {
    var viewController: ItemViewController!
    var testEventHandler: EventHandlerStub! = EventHandlerStub()
    
    override func setUp() {
        super.setUp()
        
        let windowController = ItemManagementWindowController()
        windowController.loadWindow()
        viewController = windowController.itemViewController
        viewController.eventHandler = testEventHandler
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func boxNodes() -> [NSTreeNode] {
        return (viewController.itemsController.arrangedObjects as AnyObject).children!!
    }
    
    func boxNodeCount() -> Int {
        return boxNodes().count
    }
    
    func boxAtIndex(_ index: Int) -> NSTreeNode {
        return boxNodes()[index]
    }
    
    func itemTreeNode(atBoxIndex boxIndex: Int, itemIndex: Int) -> NSTreeNode {
        let boxNode: NSTreeNode = boxAtIndex(boxIndex)
        return boxNode.children![itemIndex] as NSTreeNode
    }
    
    func boxDataStub() -> BoxData {
        return BoxData(boxId: BoxId(0), title: "irrelevant", itemData: [])
    }
    
    func itemDataStub() -> ItemData {
        return itemDataStub(parentBoxId: BoxId(666))
    }
    
    func itemDataStub(parentBoxId boxId: BoxId) -> ItemData {
        return ItemData(itemId: ItemId(0), title: "irrelevant", boxId: boxId)
    }
    
    //MARK: Nib Setup
    
    func testView_IsLoaded() {
        XCTAssertNotNil(viewController.view, "view should be set in Nib")
        XCTAssertEqual(viewController.view.className, "NSOutlineView", "view should be outline view")
        XCTAssertEqual(viewController.view, viewController.outlineView, "tableView should be alternative to view")
    }

    func testOutlineViewColumns_NamedProperly() {
        let outlineView = viewController.outlineView
        
        XCTAssertNotNil(outlineView.tableColumn(withIdentifier: kColumnNameTitle), "outline should include title column")
        XCTAssertNotNil(outlineView.tableColumn(withIdentifier: kColumnNameCount), "outline should include count column")
    }
    
    func testItemsController_IsConnected() {
        XCTAssertNotNil(viewController.itemsController)
    }
    
    func testItemsController_PreservesSelection() {
        XCTAssertTrue(viewController.itemsController.preservesSelection)
    }
    
    func testItemsController_CocoaBindings() {
        let controller = viewController.itemsController!
        let outlineView = viewController.outlineView
        let titleColumn = outlineView.tableColumn(withIdentifier: kColumnNameTitle)
        let countColumn = outlineView.tableColumn(withIdentifier: kColumnNameCount)
        
        XCTAssertTrue(hasBinding(controller, binding: NSSortDescriptorsBinding, to: viewController, throughKeyPath: "self.itemsSortDescriptors"))
        XCTAssertTrue(hasBinding(outlineView, binding: NSContentBinding, to: controller, throughKeyPath: "arrangedObjects"))
        
        XCTAssertTrue(hasBinding(titleColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.title"))
        XCTAssertTrue(hasBinding(countColumn!, binding: NSValueBinding, to: controller, throughKeyPath: "arrangedObjects.count"))
    }
    
    func testAddBoxButton_IsConnected() {
        XCTAssertNotNil(viewController.addBoxButton)
    }
    
    func testAddBoxButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addBoxButton.action, #selector(ItemViewController.addBox(_:)))
    }
    
    func testAddItemButton_IsConnected() {
        XCTAssertNotNil(viewController.addItemButton)
    }
    
    func testAddItemButton_IsWiredToAction() {
        XCTAssertEqual(viewController.addItemButton.action, #selector(ItemViewController.addItem(_:)))
    }
    
    func testAddItemButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.addItemButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
    }
    
    func testRemoveButton_IsConnected() {
        XCTAssertNotNil(viewController.removeButton)
    }

    func testRemoveButton_IsWiredToAction() {
        XCTAssertEqual(viewController.removeButton.action, #selector(ItemViewController.removeSelectedObject(_:)))
    }
    
    func testRemoveButton_CocoaBindings() {
        XCTAssertTrue(hasBinding(viewController.removeButton, binding: NSEnabledBinding, to: viewController.itemsController, throughKeyPath: "selectionIndexPath", transformingWith: "NSIsNotNil"), "enable button in virtue of itemsController selection != nil")
    }
    
    func testItemRowView_TitleCell_SetUpProperly() {
        viewController.itemsController.addObject(TestBoxNode())
        
        guard let titleCellView = viewController.outlineView.view(atColumn: 0, row: 0, makeIfNecessary: true) as? NSTableCellView
            else { XCTFail("expected NSTableCellView at (0,0)"); return }

        guard let titleTextField = titleCellView.textField else { XCTFail("expected cell view with textField"); return }

        XCTAssertTrue(titleTextField.isEditable)
        XCTAssertTrue(hasBinding(titleTextField, binding: NSValueBinding, to: titleCellView, throughKeyPath: "objectValue.title", transformingWith: "NonNilStringValueTransformer"))
    }
    
    func testItemRowView_CountCell_SetUpProperly() {
        viewController.itemsController.addObject(TestBoxNode())

        guard let countCellView: NSTableCellView = viewController.outlineView.view(atColumn: 1, row: 0, makeIfNecessary: true) as? NSTableCellView
            else { XCTFail("expected NSTableCellView at (0,0)"); return }

        guard let countTextField = countCellView.textField else { XCTFail("expected cell view with textField"); return }

        XCTAssertFalse(countTextField.isEditable, "count text field should not be editable")
        XCTAssertTrue(hasBinding(countTextField, binding: NSValueBinding, to: countCellView, throughKeyPath: "objectValue.count"))
    }
    
    
    //MARK: - 
    //MARK: Adding Boxes

    func testInitially_TreeIsEmpty() {
        XCTAssertEqual(boxNodeCount(), 0, "start with empty tree")
    }
    
    func testInitially_AddItemButtonIsDisabled() {
        XCTAssertFalse(viewController.addItemButton.isEnabled, "disable item button without boxes")
    }
    
    func testConsumeBox_WithEmptyList_AddsNode() {
        viewController.consume(boxData: boxDataStub())
        
        XCTAssertEqual(boxNodeCount(), 1, "adds item to tree")
    }
    
    func testConsumeBox_WithEmptyList_EnablesAddItemButton() {
        viewController.consume(boxData: boxDataStub())
        
        XCTAssertTrue(viewController.addItemButton.isEnabled, "enable item button by adding boxes")
    }
    
    func testConsumeBox_WithExistingBox_OrdersThemByTitle() {
        func title(_ item: NSTreeNode) -> String? {
            guard let boxNode = item.representedObject as? BoxNode else { return nil }

            return boxNode.title
        }

        // Given
        let bottomItem = TestBoxNode(title: "ZZZ")
        viewController.itemsController.addObject(bottomItem)
        XCTAssertEqual(boxNodeCount(), 1)

        // When
        let newItem = BoxData(boxId: BoxId(1), title: "AAA", itemData: [])
        viewController.consume(boxData: newItem)

        // Then
        XCTAssertEqual(boxNodeCount(), 2, "add node to existing one")
        XCTAssertEqual(title(boxAtIndex(0)), "AAA", "new node should be put before existing one")
        XCTAssertEqual(title(boxAtIndex(1)), "ZZZ")
    }

    func testAddBox_Twice_SelectsSecondBox() {
        let treeController = viewController.itemsController!
        treeController.addObject(TestBoxNode(title: "first"))
        treeController.addObject(TestBoxNode(title: "second"))
        
        XCTAssertTrue(treeController.selectedNodes.count > 0, "should auto-select")
        let selectedNode: NSTreeNode = treeController.selectedNodes[0]
        let item: TreeNode = selectedNode.representedObject as! TreeNode
        XCTAssertEqual(item.title, "second", "select latest insertion")
    }
    
    
    //MARK: Adding Items
    
    func testConsumeItem_WithoutBoxes_DoesNothing() {
        viewController.consume(itemData: itemDataStub())
        
        XCTAssertEqual(boxNodeCount(), 0, "don't add boxes or anything")
    }
    
    func testConsumeItem_WithSelectedBox_InsertsItemBelowSelectedBox() {
        // Pre-populate
        let treeController = viewController.itemsController!
        treeController.addObject(TestBoxNode(title: "first", boxId: BoxId(1)))
        treeController.addObject(TestBoxNode(title: "second", boxId: BoxId(2)))
        
        // Select first node
        let selectionIndexPath = IndexPath(index: 0)
        treeController.setSelectionIndexPath(selectionIndexPath)
        let selectedBox = treeController.selectedNodes[0].representedObject as! TreeNode
        XCTAssertEqual(selectedBox.children.count, 0, "box starts empty")
        
        viewController.consume(itemData: itemDataStub(parentBoxId: BoxId(1)))
        
        // Then
        if selectedBox.children.count > 0 {
            XCTAssert(selectedBox.children[0].isLeaf)
        } else {
            XCTFail("box contains no child")
        }
    }
    
    
    //MARK: Displaying Box Data
    
    func testDisplayData_Once_PopulatesTree() {
        let itemId = ItemId(444)
        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
        let boxId = BoxId(1122)
        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])

        viewController.displayBoxData([boxData])
        
        XCTAssertEqual(boxNodeCount(), 1)
        let soleBoxTreeNode = boxAtIndex(0)
        let boxNode = soleBoxTreeNode.representedObject as! BoxNode
        XCTAssertEqual(boxNode.boxId, boxId)
        
        let itemNodes = soleBoxTreeNode.children! as [NSTreeNode]
        XCTAssertEqual(itemNodes.count, 1)
        if let soleItemTreeNode = itemNodes.first {
            let itemNode = soleItemTreeNode.representedObject as! ItemNode
            XCTAssertEqual(itemNode.itemId, itemId)
        }
    }
    
    func testDisplayData_Twice_ReplacedNodes() {
        let itemId = ItemId(444)
        let itemData = ItemData(itemId: itemId, title: "irrelevant item title")
        let boxId = BoxId(1122)
        let boxData = BoxData(boxId: boxId, title: "irrelevant box title", itemData: [itemData])
        
        viewController.displayBoxData([boxData])
        viewController.displayBoxData([boxData])
        
        XCTAssertEqual(boxNodeCount(), 1)
        XCTAssertEqual(boxAtIndex(0).children!.count, 1)
    }

    
    //MARK: -
    //MARK: Removing Boxes
    
    func testRemoveBox_RemovesNodeFromTree() {
        let treeController = viewController.itemsController!
        treeController.addObject(TestBoxNode(title: "the box"))
        treeController.setSelectionIndexPath(IndexPath(index: 0))
        XCTAssertEqual(boxNodeCount(), 1)
        
        viewController.removeSelectedObject(self)
        
        XCTAssertEqual(boxNodeCount(), 0)
    }
    
    func testRemoveItem_RemovesNodeFromTree() {
        let treeController = viewController.itemsController!
        let rootNode = TestBoxNode(title: "the box")
        rootNode.children = [TestBoxNode(title: "the item")]
        treeController.addObject(rootNode)
        treeController.setSelectionIndexPath(IndexPath(arrayLiteral: 0, 0))
        XCTAssertEqual(boxNodes().first!.children!.count, 1)
        
        viewController.removeSelectedObject(self)
        
        XCTAssertEqual(boxNodeCount(), 1)
        XCTAssertEqual(boxNodes().first!.children!.count, 0)
    }

}
