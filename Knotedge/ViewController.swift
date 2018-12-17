//
//  ViewController.swift
//  Knotedge
// Hey It's me
//  Created by Sifei LI on 20/11/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class ViewController: UIViewController {
    
    var database:Connection!
    let TABLE_PROFILE = Table("profile")
    let PROFILE_ID =  Expression<Int>("profile_id")
    let PROFILE_FIRST_NAME = Expression<String>("profile_first_name")
    let PROFILE_LAST_NAME = Expression<String>("profile_last_name")
    let PROFILE_EMAIL = Expression<String>("profile_email")
    let PROFILE_PHOTO = Expression<Blob>("profile_photo")
    
    let TABLE_OBJECT = Table("object")
    let OBJECT_ID =  Expression<Int>("object_id")
    let OBJECT_NAME = Expression<String>("object_name")
    let OBJECT_DATE = Expression<String>("object_date")
    let OBJECT_DESCRIPTION = Expression<String>("object_description")
    let OBJECT_TYPE = Expression<String>("object_type")
    
    let TABLE_BOOK = Table("book")
    let BOOK_ID =  Expression<Int>("book_id")
    let BOOK_NAME = Expression<String>("book_name")
    let BOOK_AUTHOR = Expression<String>("book_author")
    let BOOK_DATE = Expression<String>("book_date")
    let BOOK_DESCRIPTION = Expression<String>("book_description")
    
    let TABLE_TAG = Table("tag")
    let TAG_ID =  Expression<Int>("tag_id")
    let TAG_NAME = Expression<String>("tag_name")
    
    let TABLE_NOTE = Table("note")
    let NOTE_ID =  Expression<Int>("note_id")
    let NOTE_TITLE = Expression<String>("note_title")
    let NOTE_CONTENT = Expression<String>("note_content")
    let NOTE_CREATE_DATE = Expression<String>("note_create_date")
    let NOTE_EDIT_DATE = Expression<String>("note_edit_date")
    
    let TABLE_RELATION_OBJECTS = Table("relation_objects")
    let TABLE_RELATION_OBJECT_TAG = Table("relation_object_tag")
    let TABLE_RELATION_BOOK_TAG = Table("relation_book_tag")
    let TABLE_RELATION_OBJECT_NOTE = Table("relation_object_note")
    let TABLE_RELATION_BOOK_NOTE = Table("relation_book_note")
    
    var tableExist = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connecxion to the BD
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("knotedge").appendingPathExtension("sqlite3")
            let base = try Connection(fileUrl.path)
            self.database = base;
        }
        catch {
            print (error)
        }
    }
    
    func createTables() {
        if !self.tableExist {
            self.tableExist = true
            
            let dropTableProfile = self.TABLE_PROFILE.drop(ifExists:true)
            
            let createTableProfile = self.TABLE_PROFILE.create { table in
                table.column(self.PROFILE_ID, primaryKey: true)
                table.column(self.PROFILE_FIRST_NAME)
                table.column(self.PROFILE_LAST_NAME)
                table.column(self.PROFILE_EMAIL)
                table.column(self.PROFILE_PHOTO)
            }
            
            let dropTableObject = self.TABLE_OBJECT.drop(ifExists:true)
            
            let createTableObject = self.TABLE_OBJECT.create { table in
                table.column(self.OBJECT_ID, primaryKey: true)
                table.column(self.OBJECT_NAME)
                table.column(self.OBJECT_DATE)
                table.column(self.OBJECT_DESCRIPTION)
                table.column(self.OBJECT_TYPE)
            }
            
            let dropTableBook = self.TABLE_BOOK.drop(ifExists:true)
            
            let createTableBook = self.TABLE_BOOK.create { table in
                table.column(self.BOOK_ID, primaryKey: true)
                table.column(self.BOOK_NAME)
                table.column(self.BOOK_AUTHOR)
                table.column(self.BOOK_DATE)
                table.column(self.BOOK_DESCRIPTION)
            }
            
            let dropTableTag = self.TABLE_TAG.drop(ifExists:true)
            
            let createTableTag = self.TABLE_TAG.create { table in
                table.column(self.TAG_ID, primaryKey: true)
                table.column(self.TAG_NAME)
            }
            
            let dropTableNote = self.TABLE_NOTE.drop(ifExists:true)
            
            let createTableNote = self.TABLE_NOTE.create { table in
                table.column(self.NOTE_ID, primaryKey: true)
                table.column(self.NOTE_TITLE)
                table.column(self.NOTE_CONTENT)
                table.column(self.NOTE_EDIT_DATE)
                table.column(self.NOTE_CREATE_DATE)
            }
            
            do {
                try self.database.run(dropTableProfile)
                try self.database.run(createTableProfile)
                try self.database.run(dropTableObject)
                try self.database.run(createTableObject)
                try self.database.run(dropTableBook)
                try self.database.run(createTableBook)
                try self.database.run(dropTableTag)
                try self.database.run(createTableTag)
                try self.database.run(dropTableNote)
                try self.database.run(createTableNote)
                print ("Table profile est créée")
            }
            catch {
                print (error)
            }
        }

    }
    
    @IBAction func experiment(){
        
    }

}
