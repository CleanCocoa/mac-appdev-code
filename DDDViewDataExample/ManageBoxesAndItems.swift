import Cocoa

public class ManageBoxesAndItems {
    public init() { }
    
    lazy var repository: BoxRepository = ServiceLocator.boxRepository()
    
    lazy var windowController: ItemManagementWindowController! = {
        let controller = ItemManagementWindowController()
        controller.loadWindow()
        return controller
    }()
        
    public lazy var itemViewController: ItemViewController = {
        return self.windowController.itemViewController
    }()
    
    public func showBoxManagementWindow() {
        prepareWindow()
        showWindow()
    }
    
    func prepareWindow() {
        windowController.repository = self.repository
    }
    
    func showWindow() {
        windowController.showWindow(self)
        windowController.window?.makeKeyAndOrderFront(self)
    }
}
