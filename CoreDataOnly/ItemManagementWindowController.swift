import Cocoa

public let kItemManagementWindowNibName: String = "ItemManagementWindowController"

open class ItemManagementWindowController: NSWindowController {
        
    var repository: BoxRepository? {
        didSet {
            guard hasValue(repository) else {
                return
            }
            
            itemViewController.repository = repository
        }
    }
    
    @IBOutlet open var itemViewController: ItemViewController!
    
    /// Initialize using the default Nib
    public convenience init() {
        self.init(windowNibName: kItemManagementWindowNibName)
    }

    open override func windowDidLoad() {
        super.windowDidLoad()

        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }
}
