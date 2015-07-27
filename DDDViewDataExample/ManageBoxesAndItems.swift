import Cocoa

public class ManageBoxesAndItems {
    public init() { }
    
    lazy var eventHandler: HandleBoxAndItemModifications! = {
        let provisioningService = ProvisioningService(repository: ServiceLocator.boxRepository())
        return HandleBoxAndItemModifications(provisioningService: provisioningService)
    }()
    
    lazy var windowController: ItemManagementWindowController! = {
        let controller = ItemManagementWindowController()
        controller.loadWindow()
        controller.eventHandler = self.eventHandler
        return controller
    }()
        
    public lazy var itemViewController: ItemViewController = {
        return self.windowController.itemViewController
    }()
    
    public func showBoxManagementWindow() {
        showWindow()
    }
        
    func showWindow() {
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
}
