//
//  AppDelegate.swift
//  hnBar
//
//  Created by Kun Su on 2015-03-12.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Cocoa
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!

    @IBOutlet weak var menu: NSMenu!
    
    let statusBarItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
    lazy var windowController = SettingWindow(windowNibName: "SettingWindow")
    
    var itemDict: [NSMenuItem:String] = Dictionary()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        
        if let icon = NSImage(named: "AppIcon"){
            icon.setTemplate(true)
            statusBarItem.image = icon
            statusBarItem.menu = menu
        }
        refresh()
    }
    
    func refresh() {
        
        for (index: NSMenuItem, url: String) in itemDict {
            menu.removeItem(index)
        }
        self.itemDict.removeAll(keepCapacity: false)
        
        if let url = NSURL(string: "http://hn.algolia.com/api/v1/search?tags=front_page") {
            
            let request = NSURLRequest(URL: url)
            let queue:NSOperationQueue = NSOperationQueue()
            
            NSURLConnection.sendAsynchronousRequest(request, queue: queue,
                completionHandler:{ response, data, error in
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode == 200 {
                            let resp = JSON(data:data)
                            for (index: String, subJson: JSON) in resp["hits"] {
                                let title = subJson["title"].string
                                var item:NSMenuItem = NSMenuItem(title: title!,
                                    action: Selector("itemPressed:"),
                                    keyEquivalent: "")
                                item.enabled = true
                                self.itemDict[item] = subJson["url"].string
                                self.menu.insertItem(item, atIndex: 0)
                            }
                        }
                    }else{
                        var item:NSMenuItem = NSMenuItem(title: "Network error",
                            action: "",
                            keyEquivalent: "")
                        self.menu.insertItem(item, atIndex: 0)
                    }
            })
        }
    }
    @IBAction func openSetting(sender: AnyObject) {
        
        windowController.showWindow(sender)
        
    }
    
    @IBAction func refreshClicked(sender: AnyObject) {
        
        refresh()
    }
    
    @IBAction func itemPressed(sender:NSMenuItem) {
        if let url = NSURL(string: itemDict[sender]!){
            if NSWorkspace.sharedWorkspace().openURL(url) {
                println("url successfully opened")
            }else{
                let alert = NSAlert()
                alert.icon = NSImage(named:"alert-circled")
                alert.messageText = "Can not open: " + itemDict[sender]!
                alert.runModal()
            }
        }
    }

    @IBAction func exitClicked(sender: NSMenuItem) {
        exit(0)
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
    // core data
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "k.data" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let appSupportURL = urls[urls.count - 1] as! NSURL
        return appSupportURL.URLByAppendingPathComponent("k.hnBar")
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("hnBar", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var shouldFail = false
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        let propertiesOpt = self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey], error: &error)
        if let properties = propertiesOpt {
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } else if error!.code == NSFileReadNoSuchFileError {
            error = nil
            fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil, error: &error)
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if !shouldFail && (error == nil) {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("hnBar.storedata")
            if coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                coordinator = nil
            }
        }
        
        if shouldFail || (error != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if error != nil {
                dict[NSUnderlyingErrorKey] = error
            }
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error!)
            return nil
        } else {
            return coordinator
        }
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving and Undo support
    
    @IBAction func saveAction(sender: AnyObject!) {
        
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if let moc = self.managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
            }
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                NSApplication.sharedApplication().presentError(error!)
            }
        }
    }
    
    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        if let moc = self.managedObjectContext {
            return moc.undoManager
        } else {
            return nil
        }
    }
    
    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if let moc = managedObjectContext {
            if !moc.commitEditing() {
                NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
                return .TerminateCancel
            }
            
            if !moc.hasChanges {
                return .TerminateNow
            }
            
            var error: NSError? = nil
            if !moc.save(&error) {
                // Customize this code block to include application-specific recovery steps.
                let result = sender.presentError(error!)
                if (result) {
                    return .TerminateCancel
                }
                
                let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
                let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
                let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
                let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
                let alert = NSAlert()
                alert.messageText = question
                alert.informativeText = info
                alert.addButtonWithTitle(quitButton)
                alert.addButtonWithTitle(cancelButton)
                
                let answer = alert.runModal()
                if answer == NSAlertFirstButtonReturn {
                    return .TerminateCancel
                }
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }
}

