import Foundation

public protocol HandlesItemListEvents: class {
    func createBox()
    func createItem(_ boxId: BoxId)
    
    func changeBoxTitle(_ boxId: BoxId, title: String)
    func changeItemTitle(_ itemId: ItemId, title: String, inBox boxId: BoxId)
    
    func removeBox(_ boxId: BoxId)
    func removeItem(_ itemId: ItemId, fromBox boxId: BoxId)
}
