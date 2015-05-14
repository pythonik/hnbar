//
//  SettingWindow.swift
//  hnBar
//
//  Created by Kun Su on 2015-05-08.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindowController {
    
    var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        
    }()
       
    override func windowDidLoad() {
        
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
    
    @IBAction func addClicked(sender: AnyObject) {
        println("add")
    }
    
    @IBAction func removeClicked(sender: AnyObject) {
    }
}
