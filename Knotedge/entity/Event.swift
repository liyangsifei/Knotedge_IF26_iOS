//
//  Event.swift
//  Knotedge
//
//  Created by Sifei LI on 15/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import Foundation
class Event: Object {
    override init(name: String, date: String, description: String, type: String) {
        super.init(name: name, date: date, description: description, type: "event")
    }
}
