//
//  Object.swift
//  Knotedge
//
//  Created by Sifei LI on 15/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import Foundation
class Object {
    var id: Int = 0
    var name: String
    var date: String
    var description: String
    var type: String
    
    init(name: String, date: String, description: String, type: String ) {
        self.name = name
        self.date = date
        self.description = description
        self.type = type
    }
}
