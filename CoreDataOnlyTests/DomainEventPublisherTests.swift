import Cocoa
import XCTest

@testable import CoreDataOnly

class DomainEventPublisherTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testSingleton() {
        let first = DomainEventPublisher.sharedInstance
        let second = DomainEventPublisher.sharedInstance
        
        DomainEventPublisher.resetSharedInstance()
        
        let third = DomainEventPublisher.sharedInstance
        
        XCTAssert(first === second)
        XCTAssert(first !== third)
    }
    
    func testManualSingleton() {
        DomainEventPublisher.sharedInstance = DomainEventPublisher()
        let first = DomainEventPublisher.sharedInstance
        let second = DomainEventPublisher.sharedInstance
        
        DomainEventPublisher.resetSharedInstance()
        
        let third = DomainEventPublisher.sharedInstance
        
        XCTAssert(first === second)
        XCTAssert(first !== third)
    }
}
