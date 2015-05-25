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
    
    @IBOutlet weak var newsTable: NSTableView!
    
    
    var managedObjectContext: NSManagedObjectContext? = {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.managedObjectContext!
        
    }()
    
    var npi = NSProgressIndicator()
    var newsArray = [News]()
    
    override func windowDidLoad() {
        interest.formatter = OnlyNumber()
        super.windowDidLoad()
        NSApp.activateIgnoringOtherApps(true)
        newsTable.target = self
        newsTable.doubleAction = Selector("doubleClick:")
    }
    
    func doubleClick(sender:AnyObject) {
        if newsTable.selectedRow < 0 {
           return
        }
        
        if let url = NSURL(string: newsArray[newsTable.selectedRow].url!){
            if NSWorkspace.sharedWorkspace().openURL(url) {
                println("url successfully opened")
            }else{
                let alert = NSAlert()
                alert.icon = NSImage(named:"alert-circled")
                alert.messageText = "Can not open: " + newsArray[newsTable.selectedRow].url!
                alert.runModal()
            }
        }
    }
    
    @IBAction func prePage(sender: AnyObject) {
        
        
    }
    @IBAction func nextPage(sender: AnyObject) {
        
    }
    
    func synchrousSearch(query:NSURL) -> (NSData?, NSURLResponse?, NSError?) {
        let request = NSURLRequest(URL: query)
        var response: NSURLResponse?
        var error: NSError?
        var data:NSData? = NSURLConnection.sendSynchronousRequest(request,
            returningResponse: &response, error: &error)!
        return (data, response, error)
    }
}

extension SettingWindow: NSTableViewDataSource {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return newsArray.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
            var cellView =  NSTextFieldCell()
            if tableColumn!.identifier == "title" {
                let news = self.newsArray[row]
                cellView.stringValue = news.title!
            }
        if tableColumn!.identifier == "points" {
            let news = self.newsArray[row]
            cellView.stringValue = "0"
            if let v = news.points {
                cellView.stringValue = v.stringValue
            }
        }
            return cellView
    }
}


extension SettingWindow: NSTableViewDelegate {
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        // something is selected
        if tags.selectedObjects.count > 0 {
            // if it is legit item
            if let tag = tags.selectedObjects[0] as? Tag {
                // if optional var name is not nil
                if let query = tag.name {
                    if let url = NSURL(string: "http://hn.algolia.com/api/v1/search?query=\(query)") {
                        let (data, response, error) = synchrousSearch(url)
                        if let httpResponse = response as? NSHTTPURLResponse {
                            if httpResponse.statusCode == 200 {
                                self.newsArray.removeAll(keepCapacity: false)
                                let resp = JSON(data:data!)
                                for (index: String, subJson: JSON) in resp["hits"] {
                                    var n = News()
                                    n.title = subJson["title"].string!
                                    n.url = subJson["url"].string!
                                    n.points = subJson["points"].int!
                                    self.newsArray.append(n)
                                }
                            }
                            self.newsTable.reloadData()
                        }
                    }
                }
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