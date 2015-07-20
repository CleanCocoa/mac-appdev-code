import Foundation

public typealias UserInfo = [NSObject : AnyObject]

public protocol DomainEvent {
    
    static var eventName: String { get }
    
    init(userInfo: UserInfo)
    func userInfo() -> UserInfo
}

public func notification<T: DomainEvent>(event: T) -> NSNotification {
    return NSNotification(name: T.eventName, object: nil, userInfo: event.userInfo())
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
        let boxIdData = userInfo["id"] as! NSNumber
        self.init(boxId: BoxId(boxIdData), title: userInfo["title"] as! String)
    }
    
    public func userInfo() -> UserInfo {
        // TODO replace NSNumber(...) by using StringLiteralConvertible
        return [
            "id": NSNumber(longLong: boxId.identifier),
            "title": title
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
        let boxIdData = boxData["id"] as! NSNumber
        self.boxId = BoxId(boxIdData)
        
        let itemData = userInfo["item"] as! UserInfo
        let itemIdData = itemData["id"] as! NSNumber
        self.itemId = ItemId(itemIdData)
        self.itemTitle = itemData["title"] as! String
    }
    
    public func userInfo() -> UserInfo {
        return [
            "box" : [
                "id" : NSNumber(longLong: boxId.identifier)
            ],
            "item" : [
                "id" : NSNumber(longLong: itemId.identifier),
                "title": itemTitle
            ]
        ]
    }
}
