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

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let icon = NSImage(named: "AppIcon"){
            icon.setTemplate(true)
            statusBarItem.image = icon
            statusBarItem.menu = menu
        }
        fetchNews()
    }
    
    func refresh()
    {
        
        if let url = NSURL(string: "http://hn.algolia.com/api/v1/search?tags=front_page"){
            let request = NSURLRequest(URL: url)
            let queue:NSOperationQueue = NSOperationQueue()
            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ response, data, error in
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200{
                        let resp = JSON(data:data)
                        for (index: String, subJson: JSON) in resp["hits"]
                        {
                            let title = subJson["title"].string
                            println(subJson["url"])
                            var item:NSMenuItem = NSMenuItem(title: title!, action: Selector("itemPressed:"), keyEquivalent: "")
                            item.enabled = true
                            self.menu.insertItem(item, atIndex: 0)
                        }
                    }
                    else
                    {
                        
                    }
                }
            })
        }
    }
    
    func fetchNews()
    {
        refresh()
    }
    
    @IBAction func itemPressed(sender:NSMenuItem)
    {
        println(sender.title)
    }

    @IBAction func exitClicked(sender: NSMenuItem) {
        exit(0)
    }
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

