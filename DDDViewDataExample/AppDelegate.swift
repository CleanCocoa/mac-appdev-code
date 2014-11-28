//
//  AppDelegate.swift
//  DDDViewDataExample
//
//  Created by Christian Tietze on 16.11.14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

import Cocoa

let kErrorDomain = "DDDViewDataExampleErrorDomain"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    func notificationCenter() -> NSNotificationCenter {
        return NSNotificationCenter.defaultCenter()
    }
    
    lazy var persistentStack: PersistentStack = {
        let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent("ItemModel.sqlite");
        let modelURL = NSBundle.mainBundle().URLForResource(kDefaultModelName, withExtension: "momd")
        
        let persistentStack = PersistentStack(storeURL: storeURL, modelURL: modelURL!)
        
        self.notificationCenter().addObserver(persistentStack, selector: "objectContextWillSave", name: NSManagedObjectContextWillSaveNotification, object: persistentStack.managedObjectContext)
        
        return persistentStack
    }()

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "de.christiantietze.DDDViewDataExample" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as NSURL
        let directory = appSupportURL.URLByAppendingPathComponent("de.christiantietze.DDDViewDataExample")
        
        self.guardApplicationDocumentsDirectory(directory)
        
        return directory
    }()
    
    private func guardApplicationDocumentsDirectory(directory: NSURL) {
        // Make sure the application files directory is there
        var error: NSError? = nil
        var success: Bool = true
        let propertiesOpt = directory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        
        if let properties = propertiesOpt {
            if let isDirectory = properties[NSURLIsDirectoryKey]!.boolValue {
                return
            }
            
            let userInfo = NSMutableDictionary()
            userInfo[NSLocalizedDescriptionKey] = "Failed to initialize the persistent stack"
            userInfo[NSLocalizedFailureReasonErrorKey] = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
            
            if error != nil {
                userInfo[NSUnderlyingErrorKey] = error
            }
            
            error = NSError(domain: kErrorDomain, code: 1, userInfo: userInfo)
            success = false
        } else if error!.code == NSFileReadNoSuchFileError {
            let fileManager = NSFileManager.defaultManager()
            if fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error) {
                return
            }
            
            let userInfo = NSMutableDictionary()
            userInfo[NSLocalizedDescriptionKey] = "Failed to create the application documents directory"
            userInfo[NSLocalizedFailureReasonErrorKey] = "Creation of \(self.applicationDocumentsDirectory.path) failed."
            
            if error != nil {
                userInfo[NSUnderlyingErrorKey] = error
            }
            
            error = NSError(domain: kErrorDomain, code: 1, userInfo: userInfo)
            success = false
        }
        
        if !success {
            NSApplication.sharedApplication().presentError(error!)
            
            abort()
        }
    }
    
    //MARK: -
    //MARK: NSAppDelegate callbacks
    
    lazy var manageBoxesAndItems: ManageBoxesAndItems! = ManageBoxesAndItems()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        ServiceLocator.sharedInstance.managedObjectContext = persistentStack.managedObjectContext
        manageBoxesAndItems.showBoxManagementWindow()
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        return self.persistentStack.saveToTerminate(sender)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        self.notificationCenter().removeObserver(persistentStack, name: NSManagedObjectContextWillSaveNotification, object: persistentStack.managedObjectContext)
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        return self.persistentStack.undoManager()
    }
}

