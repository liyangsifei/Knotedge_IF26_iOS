//
//  ProfileViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 18/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    
    @IBOutlet weak var countNoteBtn: UIButton!
    @IBOutlet weak var countClassBtn: UIButton!
    @IBOutlet weak var countBookBtn: UIButton!
    @IBOutlet weak var countTagBtn: UIButton!
    
    var database:Connection!
    let TABLE_PROFILE = Table("profile")
    let PROFILE_ID =  Expression<Int>("profile_id")
    let PROFILE_FIRST_NAME = Expression<String>("profile_first_name")
    let PROFILE_LAST_NAME = Expression<String>("profile_last_name")
    let PROFILE_EMAIL = Expression<String>("profile_email")
    let PROFILE_PHOTO = Expression<String>("profile_photo")
    
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
        connextionBD()
        createTables()
        setDefaultUser()
        counts()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        counts()
    }
    
    func connextionBD () {
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
    
    func insertObject() {
        let name = "name"
        let type = "tp"
        let date = "dt"
        let description = "des"
        let insert = self.TABLE_OBJECT.insert(self.OBJECT_NAME <- name, self.OBJECT_DATE <- date, self.OBJECT_DESCRIPTION <- description, self.OBJECT_TYPE <- type)
        do {
            try self.database.run(insert)
            print ("OBJ inserted")
        } catch {
            print (error)
        }
    }
    
    func counts() {
        var nbNote = 0
        var nbClass = 0
        var nbBook = 0
        var nbTag = 0
        do {
            nbNote = try self.database.scalar(TABLE_NOTE.count)
            nbClass = try self.database.scalar(TABLE_OBJECT.count)
            nbBook = try self.database.scalar(TABLE_BOOK.count)
            nbTag = try self.database.scalar(TABLE_TAG.count)
        }
        catch {
            print (error)
        }
        countClassBtn.setTitle(String(nbClass), for: UIControl.State.normal)
        countNoteBtn.setTitle(String(nbNote), for: UIControl.State.normal)
        countBookBtn.setTitle(String(nbBook), for: UIControl.State.normal)
        countTagBtn.setTitle(String(nbTag), for: UIControl.State.normal)
    }
    
    
    func createTables() {
        if !self.tableExist {
            self.tableExist = true
            
            let createTableProfile = self.TABLE_PROFILE.create { table in
                table.column(self.PROFILE_ID, primaryKey: true)
                table.column(self.PROFILE_FIRST_NAME)
                table.column(self.PROFILE_LAST_NAME)
                table.column(self.PROFILE_EMAIL)
                table.column(self.PROFILE_PHOTO)
            }
            let createTableObject = self.TABLE_OBJECT.create { table in
                table.column(self.OBJECT_ID, primaryKey: true)
                table.column(self.OBJECT_NAME)
                table.column(self.OBJECT_DATE)
                table.column(self.OBJECT_DESCRIPTION)
                table.column(self.OBJECT_TYPE)
            }
            let createTableBook = self.TABLE_BOOK.create { table in
                table.column(self.BOOK_ID, primaryKey: true)
                table.column(self.BOOK_NAME)
                table.column(self.BOOK_AUTHOR)
                table.column(self.BOOK_DATE)
                table.column(self.BOOK_DESCRIPTION)
            }
            let createTableTag = self.TABLE_TAG.create { table in
                table.column(self.TAG_ID, primaryKey: true)
                table.column(self.TAG_NAME)
            }
            let createTableNote = self.TABLE_NOTE.create { table in
                table.column(self.NOTE_ID, primaryKey: true)
                table.column(self.NOTE_TITLE)
                table.column(self.NOTE_CONTENT)
                table.column(self.NOTE_EDIT_DATE)
                table.column(self.NOTE_CREATE_DATE)
            }
            
            do {
                try self.database.run(createTableProfile)
                try self.database.run(createTableObject)
                try self.database.run(createTableBook)
                try self.database.run(createTableTag)
                try self.database.run(createTableNote)
            }
            catch {
                print (error)
            }
        }
    }
    
    func setDefaultUser() {
        var nbUser = 0
        do {
            nbUser = try self.database.scalar(TABLE_PROFILE.count)
        }
        catch {
            print (error)
        }
        if nbUser==0 {
            let fName = "SIFEI"
            let lName = "LI"
            let email = "??"
            let img: UIImage = UIImage(named:"image")!
            let imgData:NSData = img.pngData()! as NSData
            let strBase64 = imgData.base64EncodedString(options: .lineLength64Characters)
            let insert = self.TABLE_PROFILE.insert(self.PROFILE_FIRST_NAME <- fName, self.PROFILE_LAST_NAME <- lName, self.PROFILE_EMAIL <- email, self.PROFILE_PHOTO <- strBase64)
            do {
                try self.database.run(insert)
                print ("profile inserted")
            } catch {
                print (error)
            }
        }
        do {
            let users = try self.database.prepare(self.TABLE_PROFILE)
            for u in users {
                let fName = u[self.PROFILE_FIRST_NAME]
                let lName = u[self.PROFILE_LAST_NAME]
                let photoStr = u[self.PROFILE_PHOTO]
                let dataDecoded:NSData = NSData(base64Encoded: photoStr, options: .ignoreUnknownCharacters)!
                if let decodedImage = UIImage(data:dataDecoded as Data) {
                    self.profilePhoto.image = decodedImage
                }
                self.profileName.text = fName + " " + lName
            }
        } catch{
            print(error)
        }
    }
    /*
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "enterAllClass" {
            let destination = segue.destination as! AllClassesTableViewController
            var personList: [Person] = []
            var eventList: [Event] = []
            var placeList: [Place] = []
            var objectList: [Object] = []
            var allClassList: [Object] = []
            do {
                let list = try self.database.prepare(self.TABLE_OBJECT)
                var type = ""
                for item in list {
                    type = item[self.OBJECT_TYPE]
                    switch type {
                    case "person" :
                        let p = Person(name: item[self.OBJECT_NAME], date: item[self.OBJECT_DATE], description: item[self.OBJECT_DESCRIPTION], type: "person")
                        p.id = item[self.OBJECT_ID]
                        personList.append(p)
                        allClassList.append(p)
                        print("a person found")
                        break
                    case "event" :
                        let e = Event(name: item[self.OBJECT_NAME], date: item[self.OBJECT_DATE], description: item[self.OBJECT_DESCRIPTION], type: "event")
                        e.id = item[self.OBJECT_ID]
                        eventList.append(e)
                        allClassList.append(e)
                        print("an event found")
                        break
                    case "place" :
                        let p = Place(name: item[self.OBJECT_NAME], date: "", description: item[self.OBJECT_DESCRIPTION], type: "place")
                        p.id = item[self.OBJECT_ID]
                        placeList.append(p)
                        allClassList.append(p)
                        print("a place found")
                        break
                    case "object" :
                        let o = Object(name: item[self.OBJECT_NAME], date: item[self.OBJECT_DATE], description: item[self.OBJECT_DESCRIPTION], type: "object")
                        o.id = item[self.OBJECT_ID]
                        objectList.append(o)
                        allClassList.append(o)
                        print("an object found")
                        break
                    default :
                        break
                    }
                }
            } catch{
                print(error)
            }
            destination.personList = personList
            destination.allClassList = allClassList
            destination.eventList = eventList
            destination.placeList = placeList
            destination.objectList = objectList
        }
    }*/
}
