//
//  Note.swift
//  Knotedge
//
//  Created by Sifei LI on 11/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import Foundation
class Note {
    
    var id: Int
    var title: String
    var content: String
    var date_create: String
    var date_edit: String
    
    init (id: Int, title: String, content: String, date_create: String, date_edit: String) {
        self.id=id
        self.title=title
        self.content=content
        self.date_edit=date_edit
        self.date_create=date_create
    }
}
