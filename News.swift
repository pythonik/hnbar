//
//  News.swift
//  hnBar
//
//  Created by Kun Su on 2015-05-15.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Foundation
import CoreData

class News: NSManagedObject {

    @NSManaged var title: String
    @NSManaged var url: String

}
