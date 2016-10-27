import Foundation

public typealias UserInfo = [AnyHashable: Any]

public protocol DomainEvent {
    
    static var eventName: String { get }
    
    init(userInfo: UserInfo)
    func userInfo() -> UserInfo
}

public func notification<T: DomainEvent>(_ event: T) -> Notification {
    return Notification(name: Notification.Name(rawValue: T.eventName), object: nil, userInfo: event.userInfo())
}

public struct BoxProvisionedEvent: DomainEvent {
    
    public static let eventName = "Box Provisioned Event"
    
    public let boxId: BoxId
    public let title: String
    
    public init(boxId: BoxId, title: String) {
        self.boxId = boxId
        self.title = title
    }
    
    public init(userInfo: UserInfo) {
        let boxIdentfier = userInfo["id"] as! IntegerId
        self.init(boxId: BoxId(boxIdentfier), title: userInfo["title"] as! String)
    }
    
    public func userInfo() -> UserInfo {
        return [
            "id" : boxId.identifier,
            "title" : title
        ]
    }
}

public struct BoxItemProvisionedEvent: DomainEvent {
    
    public static let eventName = "Box Item Provisioned"
    
    public let boxId: BoxId
    public let itemId: ItemId
    public let itemTitle: String
    
    public init(boxId: BoxId, itemId: ItemId, itemTitle: String) {
        self.boxId = boxId
        self.itemId = itemId
        self.itemTitle = itemTitle
    }
    
    public init(userInfo: UserInfo) {
        let boxData = userInfo["box"] as! UserInfo
        let boxIdentifier = boxData["id"] as! IntegerId
        self.boxId = BoxId(boxIdentifier)
        
        let itemData = userInfo["item"] as! UserInfo
        let itemIdentifier = itemData["id"] as! IntegerId
        self.itemId = ItemId(itemIdentifier)
        self.itemTitle = itemData["title"] as! String
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : boxId.identifier
            ],
            "item" : [
                "id" : itemId.identifier,
                "title": itemTitle
            ]
        ]
    }
}
