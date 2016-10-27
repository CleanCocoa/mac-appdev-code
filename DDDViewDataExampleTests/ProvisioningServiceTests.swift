import Cocoa
import XCTest

@testable import DDDViewDataExample

class TestBoxRepository: BoxRepository {
    func nextId() -> BoxId {
        return BoxId(0)
    }
    
    func nextItemId() -> ItemId {
        return ItemId(0)
    }
    
    func addBox(_ box: Box) { }
    func removeBox(boxId: BoxId) { }
    
    func box(boxId: BoxId) -> Box? {
        return nil
    }
    
    func boxes() -> [Box] {
        return []
    }
    
    func count() -> Int {
        return 0
    }
}

class ProvisioningServiceTests: XCTestCase {
    let provisioningService = ProvisioningService(repository: TestBoxRepository())
    let publisher = MockDomainEventPublisher()
    
    override func setUp() {
        super.setUp()
        DomainEventPublisher.sharedInstance = publisher
    }
    
    override func tearDown() {
        DomainEventPublisher.resetSharedInstance()
        super.tearDown()
    }

    func testProvisionBox_PublishesDomainEvent() {
        provisioningService.provisionBox()
        
        XCTAssert(publisher.lastPublishedEvent != nil)
    }

    func testProvisionItem_PublishesDomainEvent() {
        let box = Box(boxId: BoxId(123), title: "irrelevant")
        provisioningService.provisionItem(inBox: box)
        
        let event = publisher.lastPublishedEvent as? BoxItemProvisionedEvent
        XCTAssert(hasValue(event))
        if let event = event {
            XCTAssertEqual(event.boxId, box.boxId)
        }
    }
}
