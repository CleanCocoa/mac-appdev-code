import Foundation

open class DomainEventPublisher {
        
    open static var sharedInstance: DomainEventPublisher = DomainEventPublisher()
    
    /// Reset the static `sharedInstance`, for example for testing
    open static func resetSharedInstance() {
        
        DomainEventPublisher.sharedInstance = DomainEventPublisher()
    }

    let notificationCenter: NotificationCenter
    
    public convenience init() {
        
        self.init(notificationCenter: NotificationCenter.default)
    }
    
    public init(notificationCenter: NotificationCenter) {
        
        self.notificationCenter = notificationCenter
    }
    

    //MARK: -
    //MARK: Event Publishing and Subscribing
    
    open func publish<T: DomainEvent>(_ event: T) {
        
        event.post(notificationCenter: self.notificationCenter)
    }
    
    open func subscribe<T: DomainEvent>(_ eventKind: T.Type, usingBlock block: @escaping (T) -> Void) -> DomainEventSubscription {
        
        let mainQueue = OperationQueue.main
        
        return self.subscribe(eventKind, queue: mainQueue, usingBlock: block)
    }
    
    open func subscribe<T: DomainEvent>(_ eventKind: T.Type, queue: OperationQueue, usingBlock block: @escaping (T) -> Void) -> DomainEventSubscription {
        
        let observer = notificationCenter.addObserver(forName: T.eventName, object: nil, queue: queue) {
            notification in
            
            let userInfo = notification.userInfo!
            let event: T = T(userInfo: userInfo as UserInfo)
            block(event)
        }
        
        return DomainEventSubscription(observer: observer, eventPublisher: self)
    }
    
    open func unsubscribe(_ subscriber: AnyObject) {
        
        notificationCenter.removeObserver(subscriber)
    }
}
