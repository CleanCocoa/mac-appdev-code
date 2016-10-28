import Foundation

@testable import DDDViewDataExample

/// Overrides `NotificationCenter` methods with no-op stubs
class NullNotificationCenter: NotificationCenter {
    override func addObserver(forName name: Notification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        return NSObject()
    }
    
    override func removeObserver(_ observer: Any) {
        // no op
    }
    
    override func post(_ notification: Notification) {
        // no op
    }
}

/// Doesn't actually notify anyone thanks to the no-op `NullNotificationCenter`.
class TestDomainEventPublisher: DomainEventPublisher {
    init() {
        super.init(notificationCenter: NullNotificationCenter())
    }
}

class MockDomainEventPublisher: TestDomainEventPublisher {
    var lastPublishedEvent: DomainEvent?
    
    override func publish<T: DomainEvent>(_ event: T) {
        lastPublishedEvent = event
    }
}
