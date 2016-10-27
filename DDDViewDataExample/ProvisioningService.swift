import Foundation

open class ProvisioningService {
    let repository: BoxRepository
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(repository: BoxRepository) {
        self.repository = repository
    }
    
    open func provisionBox() {
        let boxId = repository.nextId()
        let box = Box(boxId: boxId, title: "New Box")
        
        repository.addBox(box)
        
        eventPublisher.publish(BoxProvisionedEvent(boxId: boxId, title: box.title))
    }
    
    open func provisionItem(inBox box: Box) {
        let itemId = repository.nextItemId()
        let item = Item(itemId: itemId, title: "New Item")

        box.addItem(item)
        
        eventPublisher.publish(BoxItemProvisionedEvent(boxId: box.boxId, itemId: itemId, itemTitle: item.title))
    }
}
