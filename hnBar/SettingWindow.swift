//
//  SettingWindow.swift
//  hnBar
//
//  Created by Kun Su on 2015-05-08.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Cocoa
import AppKit

class SettingWindow: NSWindowController {
    
    
    @IBOutlet weak var interest: NSTextField!
    
    @IBOutlet var tags: NSArrayController!
    
    
    
    var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        
    }()
    
    var npi = NSProgressIndicator()
    
    override func windowDidLoad() {
        interest.formatter = OnlyNumber()
        super.windowDidLoad()
        NSApp.activateIgnoringOtherApps(true)
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
}


extension SettingWindow: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if tags.selectedObjects.count > 0 {
            let query = tags.selectedObjects[0].name
            if let url = NSURL(string: "http://hn.algolia.com/api/v1/search?query=\(query)") {
                println(url)
                let request = NSURLRequest(URL: url)
                let queue:NSOperationQueue = NSOperationQueue()
                
                NSURLConnection.sendAsynchronousRequest(request, queue: queue,
                    completionHandler:{ response, data, error in
                        if let httpResponse = response as? NSHTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                let resp = JSON(data:data)
                                for (index: String, subJson: JSON) in resp["hits"] {
                                    println(subJson["title"].string)
                                    println(subJson["url"].string)
                                }
                            }
                        }
                })
            }
        }
    }
}

class OnlyNumber: NSFormatter {
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        return nil
    }
    
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>,
                                 forString string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        return true
    }
    
    override func isPartialStringValid(partialString: String,
        newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        if(partialString.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) != nil) {
            NSBeep()
            return false
        }
        
        return true
    }
    
}