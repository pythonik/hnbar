//
//  SettingWindow.swift
//  hnBar
//
//  Created by Kun Su on 2015-05-08.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Cocoa

class SettingWindow: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
    
}

extension SettingWindow: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 1
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        println("HERE")
        var cellView: NSTableCellView = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! NSTableCellView
        if tableColumn!.identifier == "tags" {
            cellView.textField?.stringValue = "python"
        }
        return cellView
    }
    
}

extension SettingWindow: NSTableViewDelegate {
    
}
