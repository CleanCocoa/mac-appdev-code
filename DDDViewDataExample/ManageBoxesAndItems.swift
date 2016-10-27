import Cocoa

open class ManageBoxesAndItems {
    public init() { }
    
    lazy var eventHandler: HandleBoxAndItemModifications! = {
        let provisioningService = ProvisioningService(repository: ServiceLocator.boxRepository())
        return HandleBoxAndItemModifications(provisioningService: provisioningService)
    }()
    
    lazy var presenter: DisplayBoxesAndItems! = {
        let service = DisplayBoxesAndItems()
        return service
    }()

    lazy var windowController: ItemManagementWindowController! = {
        let controller = ItemManagementWindowController()
        controller.loadWindow()
        controller.eventHandler = self.eventHandler
        self.presenter.consumer = controller.itemViewController
        return controller
    }()
        
    open lazy var itemViewController: ItemViewController = {
        return self.windowController.itemViewController
    }()
    
    open func showBoxManagementWindow() {
        displayBoxes()
        showWindow()
    }
    
    func displayBoxes() {
        let repository = ServiceLocator.boxRepository()
        let allBoxes = repository.boxes()
        let allBoxData = boxData(allBoxes)
        
        windowController.displayBoxData(allBoxData)
    }
    
    func boxData(_ boxes: [Box]) -> [BoxData] {
        let allBoxData: [BoxData] = boxes.map() { (box: Box) -> BoxData in
            let allItemData: [ItemData] = self.itemData(box.items)
            
            return BoxData(boxId: box.boxId, title: box.title, itemData: allItemData)
        }
        
        return allBoxData
    }
    
    func itemData(_ items: [Item]) -> [ItemData] {
        return items.map() { (item: Item) -> ItemData in
            return ItemData(itemId: item.itemId, title: item.title)
        }
    }
    
    func showWindow() {
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
}
