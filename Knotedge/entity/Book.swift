
//
//  Book.swift
//  Knotedge
//
//  Created by Sifei LI on 15/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import Foundation
class Book {
    var id: Int = 0
    var name: String
    var author: String
    var date: String
    var description: String
    
    init(name: String, author: String, date: String, description: String) {
        self.name = name
        self.author = author
        self.date = date
        self.description = description
    }
    
}
