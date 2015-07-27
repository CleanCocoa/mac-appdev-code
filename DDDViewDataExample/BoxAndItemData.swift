import Foundation

public protocol HandlesItemListEvents: class {
    func createBox()
    func createItem(boxId: BoxId)
    
    func changeBoxTitle(boxId: BoxId, title: String)
    func changeItemTitle(itemId: ItemId, title: String, inBox boxId: BoxId)
    
    func removeBox(boxId: BoxId)
    func removeItem(itemId: ItemId, fromBox boxId: BoxId)
}
