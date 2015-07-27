import Foundation
import CoreData

public class ProvisioningService {
    let repository: BoxRepository
    
    var eventPublisher: DomainEventPublisher {
        return DomainEventPublisher.sharedInstance
    }
    
    public init(repository: BoxRepository) {
        self.repository = repository
    }
    
    public func provisionBox() {
        let boxId = repository.nextId()
        let title = "New Box"
        
        repository.addBoxWithId(boxId, title: title)
        
        eventPublisher.publish(BoxProvisionedEvent(boxId: boxId, title: title))
    }
    
    public func provisionItem(inBox box: BoxType) {
        let itemId = repository.nextItemId()
        let title = "New Item"
        
        box.addItemWithId(itemId, title: title)
        
        eventPublisher.publish(BoxItemProvisionedEvent(boxId: box.boxId, itemId: itemId, itemTitle: title))
    }
}