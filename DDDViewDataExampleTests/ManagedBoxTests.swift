import Cocoa
import XCTest

import DDDViewDataExample

class BoxCoreDataTestCase: CoreDataTestCase {
    var repository: CoreDataBoxRepository!
    
    override func setUp() {
        super.setUp()
        repository = CoreDataBoxRepository(managedObjectContext: context)
    }
    
    func createBoxWithId(boxId: BoxId, title: String) {
        Box.insertBoxWithId(boxId, title: title, inManagedObjectContext: context)
    }
    
    func createAndFetchBoxWithId(boxId: BoxId, title: String) -> Box? {
        createBoxWithId(boxId, title: title)
        
        return repository.boxWithId(boxId)
    }
}

class BoxTests: BoxCoreDataTestCase {
    
    func allBoxes() -> [Box]? {
        let request = NSFetchRequest(entityName: Box.entityName())
        let result: [AnyObject]
        
        do {
            try result = context.executeFetchRequest(request)
        } catch {
            XCTFail("fetching all boxes failed")
            return nil
        }
        
        guard let boxes = result as? [Box] else {
            return nil
        }
        
        return boxes
    }
    
    func allItems() -> [Item]? {
        let request = NSFetchRequest(entityName: Item.entityName())
        let result: [AnyObject]
        
        do {
            try result = context.executeFetchRequest(request)
        } catch {
            XCTFail("fetching all items failed")
            return nil
        }
        
        guard let items = result as? [Item] else {
            return nil
        }
        
        return items
    }

    func testChangingFetchedBoxTitle_PersistsChanges() {
        let boxId = BoxId(1234)
        let box = createAndFetchBoxWithId(boxId, title: "before")
        
        XCTAssert(hasValue(box))
        if let box = box {
            box.title = "new title"

            let foundBox = allBoxes()!.first! as Box
            XCTAssertEqual(foundBox.title, "new title")
        }
    }
    
    func testChangingFetchedBoxTitle_ToEmptyString_PersistsChanges() {
        let boxId = BoxId(1234)
        let box = createAndFetchBoxWithId(boxId, title: "before")
        
        XCTAssert(hasValue(box))
        if let box = box {
            box.title = ""
            
            let foundBox = allBoxes()!.first! as Box
            XCTAssertEqual(foundBox.title, "")
        }
    }
    
    func testAddingItemToFetchedBox_PersistsChanges() {
        let boxId = BoxId(1234)
        let box = createAndFetchBoxWithId(boxId, title: "irrelevant")
        
        XCTAssert(hasValue(box))
        if let box = box {
            let itemId = ItemId(6789)
            let itemTitle = "the item"
            box.addItemWithId(itemId, title: itemTitle)
            
            let box = allBoxes()!.first! as Box
            XCTAssertEqual(box.items.count, 1, "contains item")
            
            let item = box.items.anyObject() as? Item
            XCTAssert(hasValue(item))
            if let item = item {
                XCTAssertEqual(item.itemId, itemId)
                XCTAssertEqual(item.title, itemTitle)
            }
        }
    }

}
