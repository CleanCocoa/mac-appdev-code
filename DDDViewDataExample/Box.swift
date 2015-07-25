import Cocoa

public protocol BoxRepository {
    func nextId() -> BoxId
    func nextItemId() -> ItemId
    func addBoxWithId(boxId: BoxId, title: String)
    func removeBox(boxId boxId: BoxId)
    func boxes() -> [Box]
    func boxWithId(boxId: BoxId) -> Box?
    func count() -> Int
}
