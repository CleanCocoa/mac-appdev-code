import Cocoa
import XCTest

import DDDViewDataExample

class ManagedBoxTests: CoreDataTestCase {
    var repository: CoreDataBoxRepository?
    
    override func setUp() {
        super.setUp()
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func allBoxes() -> [ManagedBox]? {
        let request = NSFetchRequest(entityName: ManagedBox.entityName())
        let result: [AnyObject]
        
        do {
            try result = context.executeFetchRequest(request)
        } catch {
            XCTFail("fetching all boxes failed")
            return nil
        }
        
        guard let boxes = result as? [ManagedBox] else {
            return nil
        }
        
        return boxes
    }
    
    func allItems() -> [ManagedItem]? {
        let request = NSFetchRequest(entityName: ManagedItem.entityName())
        let result: [AnyObject]
        
        do {
            try result = context.executeFetchRequest(request)
        } catch {
            XCTFail("fetching all items failed")
            return nil
        }
        
        guard let items = result as? [ManagedItem] else {
            return nil
        }
        
        return items
    }

    func testChangingFetchedBoxTitle_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "before", inManagedObjectContext: context)
        
        if let box = repository!.box(boxId: boxId) {
            box.title = "new title"

            let foundBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "new title")
        } else {
            XCTFail("box not found")
        }
    }
    
    func testChangingFetchedBoxTitle_ToEmptyString_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "before", inManagedObjectContext: context)
        
        if let box = repository!.box(boxId: boxId) {
            box.title = ""
            
            let foundBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(foundBox.title, "")
        } else {
            XCTFail("box not found")
        }
    }
    
    func testAddingItemToFetchedBox_PersistsChanges() {
        let boxId = BoxId(1234)
        ManagedBox.insertManagedBox(boxId, title: "irrelevant", inManagedObjectContext: context)
        
        if let box = repository!.box(boxId: boxId) {
            let itemId = ItemId(6789)
            let item = Item(itemId: itemId, title: "the item")
            box.addItem(item)
            
            let managedBox = allBoxes()!.first! as ManagedBox
            XCTAssertEqual(managedBox.items.count, 1, "contains item")
            if let managedItem = managedBox.items.anyObject() as? ManagedItem {
                XCTAssertEqual(managedItem.item, item)
            } else {
                XCTFail("no managed item")
            }
            
        } else {
            XCTFail("box not found")
        }
    }

}
