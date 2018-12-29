//
//  EditNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditNoteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "editNote2Cls"
    
    var database: Connection!
    let profileView = ProfileViewController()
    
    @IBOutlet weak var fieldTitle: UITextField!
    @IBOutlet weak var fieldText: UITextView!
    
    var idNote = 0
    var note = Note(title: "", content: "", date_create: "", date_edit: "")

    var listObject:[Object] = []
    var selectedObject:[Object] = []
    var listBook:[Book] = []
    var selectedBook:[Book] = []
    let sectionList = ["Class","Book"]
    
    @IBOutlet weak var classTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
        loadRelation()
        self.classTableView.delegate = self
        self.classTableView.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    func loadDetails() {
        do {
            let notes = Array(try self.database.prepare(profileView.TABLE_NOTE.filter(profileView.NOTE_ID == self.idNote)))
            for n in notes {
                if n[profileView.NOTE_ID] == self.idNote {
                    self.note.id = n[profileView.NOTE_ID]
                    self.note.title = n[profileView.NOTE_TITLE]
                    self.note.content = n[profileView.NOTE_CONTENT]
                    self.note.date_create = n[profileView.NOTE_CREATE_DATE]
                    self.note.date_edit = n[profileView.NOTE_EDIT_DATE]
                }
            }
        } catch{
            print(error)
        }
        self.fieldTitle.text = self.note.title
        self.fieldText.text = self.note.content
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateNote()
        updateRelation()
    }
    
    func updateNote() {
        let date = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let currentDate = dateFormat.string(from: date as Date) as String
        
        let sql = profileView.TABLE_NOTE.filter(profileView.NOTE_ID == self.idNote)
        let newTitle = fieldTitle.text!
        let newText = fieldText.text!
        do {
            try self.database.run(sql.update(profileView.NOTE_TITLE <- newTitle))
            try self.database.run(sql.update(profileView.NOTE_CONTENT <- newText))
            try self.database.run(sql.update(profileView.NOTE_EDIT_DATE <- currentDate))
        } catch {
            print(error)
        }
    }
    
    //Listeners of the keyboard Event
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)/4
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    //connexion to BD
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            return "\(self.sectionList[section])"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionList[section] {
        case "Class" :
            return self.listObject.count
        case "Book" :
            return self.listBook.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch self.sectionList[indexPath.section] {
        case "Class" :
            cell.textLabel?.text = listObject[indexPath.row].name
            let hasItem = selectedObject.contains { (obj) -> Bool in
                if obj.id == listObject[indexPath.row].id {
                    return true
                }
                return false
            }
            if hasItem {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            return cell
        case "Book" :
            cell.textLabel?.text = listBook[indexPath.row].name
            let hasItem = selectedBook.contains { (bk) -> Bool in
                if bk.id == listBook[indexPath.row].id {
                    return true
                }
                return false
            }
            if hasItem {
                cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            } else {
                cell.accessoryType = UITableViewCell.AccessoryType.none
            }
            return cell
        default:
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch sectionList[indexPath.section] {
        case "Class":
            var hasItem = -1
            for (index,value) in self.selectedObject.enumerated() {
                if value.id == listObject[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedObject.remove(at: hasItem)
            }else{
                selectedObject.append(listObject[indexPath.row])
            }
            self.classTableView.reloadRows(at: [indexPath], with: .automatic)
        case "Book":
            var hasItem = -1
            for (index,value) in self.selectedBook.enumerated() {
                if value.id == listBook[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedBook.remove(at: hasItem)
            }else{
                selectedBook.append(listBook[indexPath.row])
            }
            self.classTableView.reloadRows(at: [indexPath], with: .automatic)
        default :
            break
        }
    }
    
    func loadRelation() {
        loadAllRelation()
        loadSelectedRelation()
    }
    
    func loadAllRelation() {
        //Objects
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT)
            for item in list {
                let obj = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: item[profileView.OBJECT_TYPE])
                obj.id = item[profileView.OBJECT_ID]
                self.listObject.append(obj)
            }
        } catch{
            print(error)
        }
        //Books
        do {
            let list = try self.database.prepare(profileView.TABLE_BOOK)
            for item in list {
                let b = Book(name: item[profileView.BOOK_NAME], author: item[profileView.BOOK_AUTHOR], date: item[profileView.BOOK_DATE], description: item[profileView.BOOK_DESCRIPTION])
                b.id = item[profileView.BOOK_ID]
                self.listBook.append(b)
            }
        } catch{
            print(error)
        }
    }
    func loadSelectedRelation() {
        
        let noteId = self.note.id
        var listIdObj: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_NOTE.filter(profileView.NOTE_ID==noteId))
            for i in ids {
                listIdObj.append(i[profileView.OBJECT_ID])
            }
        } catch{
            print(error)
        }
        do {
            let objects = try self.database.prepare(profileView.TABLE_OBJECT.filter(listIdObj.contains(profileView.OBJECT_ID)))
            for o in objects {
                let obj = Object(name: "", date: "", description: "", type: "")
                obj.id = o[profileView.OBJECT_ID]
                obj.name = o[profileView.OBJECT_NAME]
                obj.date = o[profileView.OBJECT_DATE]
                obj.description = o[profileView.OBJECT_DESCRIPTION]
                obj.type = o[profileView.OBJECT_TYPE]
                self.selectedObject.append(obj)
            }
        } catch{
            print(error)
        }
        
        var listIdBook: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_BOOK_NOTE.filter(profileView.NOTE_ID==noteId))
            for i in ids {
                listIdBook.append(i[profileView.BOOK_ID])
            }
        } catch{
            print(error)
        }
        do {
            let books = try self.database.prepare(profileView.TABLE_BOOK.filter(listIdBook.contains(profileView.BOOK_ID)))
            for b in books {
                let bk = Book(name: "", author: "", date: "", description: "")
                bk.id = b[profileView.BOOK_ID]
                bk.name = b[profileView.BOOK_NAME]
                bk.date = b[profileView.BOOK_DATE]
                bk.description = b[profileView.BOOK_DESCRIPTION]
                bk.author = b[profileView.BOOK_AUTHOR]
                self.selectedBook.append(bk)
            }
        } catch{
            print(error)
        }
    }
    
    func updateRelation() {
        let delRelBoks = profileView.TABLE_RELATION_BOOK_NOTE.filter(profileView.NOTE_ID == self.idNote)
        let delRelObjs = profileView.TABLE_RELATION_OBJECT_NOTE.filter(profileView.NOTE_ID == self.idNote)
        do {
            try self.database.run(delRelBoks.delete())
            try self.database.run(delRelObjs.delete())
        } catch {
            print(error)
        }
        for obj in selectedObject {
            let insert = profileView.TABLE_RELATION_OBJECT_NOTE.insert(profileView.NOTE_ID <- idNote, profileView.OBJECT_ID <- obj.id)
            do {
                try self.database.run(insert)
            } catch {
                print (error)
            }
        }
        for book in selectedBook {
            let insert = profileView.TABLE_RELATION_BOOK_NOTE.insert(profileView.NOTE_ID <- idNote, profileView.BOOK_ID <- book.id)
            do {
                try self.database.run(insert)
            } catch {
                print (error)
            }
        }
    }
}
