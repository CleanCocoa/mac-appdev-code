import Foundation

public class DomainEventSubscription {
    
    let observer: NSObjectProtocol
    let eventPublisher: DomainEventPublisher
    
    public init(observer: NSObjectProtocol, eventPublisher: DomainEventPublisher) {
        
        self.observer = observer
        self.eventPublisher = eventPublisher
    }
    
    deinit {
        
        eventPublisher.unsubscribe(observer)
    }
}
