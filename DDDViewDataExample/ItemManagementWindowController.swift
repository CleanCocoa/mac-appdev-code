import Cocoa

public let kItemManagementWindowNibName: String = "ItemManagementWindowController"

public class ItemManagementWindowController: NSWindowController {
    
    public weak var eventHandler: HandlesItemListEvents? {
        get {
            return self.itemViewController.eventHandler
        }
        set {
            guard let _ = self.window else {
                return
            }
            
            // Ensure Nib is loaded
            self.itemViewController.eventHandler = newValue
        }
    }
    
    @IBOutlet public var itemViewController: ItemViewController!
    
    /// Initialize using the default Nib
    public convenience init() {
        self.init(windowNibName: kItemManagementWindowNibName)
    }

    public override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
