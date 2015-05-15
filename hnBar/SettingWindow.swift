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
    
    var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        
    }()
    
    override func windowDidLoad() {
        interest.formatter = OnlyNumber()
        super.windowDidLoad()
        NSApp.activateIgnoringOtherApps(true)
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
    
    @IBAction func removeAllTag(sender: AnyObject) {
        println("remove")
        
    }
    
}

class OnlyNumber: NSFormatter {
    
    override func stringForObjectValue(obj: AnyObject) -> String? {
        return nil
    }
    
    override func getObjectValue(obj: AutoreleasingUnsafeMutablePointer<AnyObject?>, forString string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        return true
    }
    
    override func isPartialStringValid(partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>) -> Bool {
        if(partialString.rangeOfCharacterFromSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet) != nil) {
            NSBeep()
            return false
        }
        
        return true
    }
    
}