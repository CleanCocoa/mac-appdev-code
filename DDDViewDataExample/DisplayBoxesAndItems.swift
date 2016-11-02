import Cocoa

public protocol ConsumesBoxAndItem: class {
    func consume(boxData: BoxData)
    func consume(itemData: ItemData)
}

class DisplayBoxesAndItems {
    var boxProvisioningObserver: DomainEventSubscription!
    var itemProvisioningObserver: DomainEventSubscription!
    
    var consumer: ConsumesBoxAndItem?

    var publisher: DomainEventPublisher! {
        return DomainEventPublisher.sharedInstance
    }
    
    init() {
        self.subscribe()
    }
    
    func subscribe() {
        let mainQueue = OperationQueue.main
        
        boxProvisioningObserver = publisher.subscribe(BoxProvisionedEvent.self, queue: mainQueue) {
            [weak self] (event: BoxProvisionedEvent!) in

            let boxData = BoxData(boxId: event.boxId, title: event.title)
            self?.consumeBox(boxData)
        }
        
        itemProvisioningObserver = publisher.subscribe(BoxItemProvisionedEvent.self, queue: mainQueue) {
            [weak self] (event: BoxItemProvisionedEvent!) in
            
            let itemData = ItemData(itemId: event.itemId, title: event.itemTitle, boxId: event.boxId)
            self?.consumeItem(itemData)
        }
    }
    
    
    //MARK: Domain Event Callbacks
    
    var repository: BoxRepository! {
        return ServiceLocator.boxRepository()
    }
    
    //TODO: rename "consume" to something better
    func consumeBox(_ boxData: BoxData) {
        consumer?.consume(boxData: boxData)
    }
    
    func consumeItem(_ itemData: ItemData) {
        consumer?.consume(itemData: itemData)
    }
}
