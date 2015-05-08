//
//  Tag.swift
//  hnBar
//
//  Created by Kun Su on 2015-05-08.
//  Copyright (c) 2015 Kun Su. All rights reserved.
//

import Foundation
import CoreData

class Tag: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var news: NSSet

}
