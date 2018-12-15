//
//  Profile.swift
//  Knotedge
//
//  Created by Sifei LI on 15/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import Foundation
class Profile {
    var id: Int = 0
    var firstName: String
    var lastName: String
    var email: String
    var photo: String
    
    init(firstName: String, lastName: String, email: String, photo: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.photo = photo
    }
}
