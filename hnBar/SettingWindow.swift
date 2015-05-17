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
    
    @IBOutlet weak var newstable: NSTableView!
    
    
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
        
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        
    }
}

extension SettingWindow: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        println(newsArray.count)
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
        if tags.selectedObjects.count > 0 {
            
            if let tag = tags.selectedObjects[0] as? Tag {
                if let query = tag.name {
                    
                    if let url = NSURL(string: "http://hn.algolia.com/api/v1/search?query=\(query)") {
                        
                        let request = NSURLRequest(URL: url)
                        let queue:NSOperationQueue = NSOperationQueue()
                    
                        NSURLConnection.sendAsynchronousRequest(request, queue: queue,
                            completionHandler:{ response, data, error in
                                if let httpResponse = response as? NSHTTPURLResponse {
                                    if httpResponse.statusCode == 200 {
                                        self.newsArray.removeAll(keepCapacity: false)
                                        let resp = JSON(data:data)
                                        for (index: String, subJson: JSON) in resp["hits"] {
                                            println(subJson["title"].string)
                                            println(subJson["url"].string)
                                            println(subJson["points"].int)
                                            var n = News()
                                            n.title = subJson["title"].string!
                                            n.url = subJson["url"].string!
                                            n.points = subJson["points"].int!
                                            self.newsArray.append(n)
                                        }
                                    }
                                    self.newstable.reloadData()
                                }
                                
                            })
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