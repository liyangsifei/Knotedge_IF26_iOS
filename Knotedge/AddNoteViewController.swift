//
//  AddNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class AddNoteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let cellIdentifier = "obj2note"
    var database: Connection!
    let profileView = ProfileViewController()
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarItem: UIBarButtonItem!
    @IBOutlet weak var spaceBarItem: UIBarButtonItem!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var classTableView: UITableView!
    var bookList: [Book] = []
    var objectList: [Object] = []
    var selectedBook: [Book] = []
    var selectedObject: [Object] = []
    let sectionList = ["Class","Book"]
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        configureToolBar()
        loadClass()
        classTableView.delegate = self
        classTableView.dataSource = self
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
    
    func insertNote() {
        let title = titleField.text!
        let content = textField.text!
        let date = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let currentDate = dateFormat.string(from: date as Date) as String
        
        let insert = profileView.TABLE_NOTE.insert(profileView.NOTE_TITLE <- title, profileView.NOTE_CONTENT <- content, profileView.NOTE_CREATE_DATE <- currentDate, profileView.NOTE_EDIT_DATE <- currentDate)
        do {
            try self.database.run(insert)
        } catch {
            print (error)
        }
    }
    
    //Tool Bar
    func configureToolBar () {
        let toolbarButtonItem = [cancelBarItem, spaceBarItem, addBarItem]
        toolBar.setItems(toolbarButtonItem as? [UIBarButtonItem], animated: true);
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "back2main", sender: self)
    }
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        insertNote()
        insertNoteObj()
        insertNoteBook()
        performSegue(withIdentifier: "back2main", sender: self)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back2main" {
            _ = segue.destination as! MainTabBarController
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sectionList[section] {
        case "Class" :
            return self.objectList.count
        case "Book" :
            return self.bookList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch self.sectionList[indexPath.section] {
        case "Class" :
            cell.textLabel?.text = objectList[indexPath.row].name
            let hasItem = selectedObject.contains { (obj) -> Bool in
                if obj.id == objectList[indexPath.row].id {
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
            cell.textLabel?.text = bookList[indexPath.row].name
            let hasItem = selectedBook.contains { (bk) -> Bool in
                if bk.id == bookList[indexPath.row].id {
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
            cell.textLabel?.text = bookList[indexPath.row].name
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch sectionList[indexPath.section] {
        case "Class":
            var hasItem = -1
            for (index,value) in self.selectedObject.enumerated() {
                if value.id == objectList[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedObject.remove(at: hasItem)
            }else{
                selectedObject.append(objectList[indexPath.row])
            }
            self.classTableView.reloadRows(at: [indexPath], with: .automatic)
        case "Book":
            var hasItem = -1
            for (index,value) in self.selectedBook.enumerated() {
                if value.id == bookList[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedBook.remove(at: hasItem)
            }else{
                selectedBook.append(bookList[indexPath.row])
            }
            self.classTableView.reloadRows(at: [indexPath], with: .automatic)
        default :
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            return "\(self.sectionList[section])"
    }
    
    func loadClass() {
        //Objects
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT)
            for item in list {
                let obj = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: item[profileView.OBJECT_TYPE])
                obj.id = item[profileView.OBJECT_ID]
                self.objectList.append(obj)
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
                self.bookList.append(b)
            }
        } catch{
            print(error)
        }
    }
    func getLastInsertedNote() -> Int {
        var idNote = 0
        do {
            let notes = try self.database.prepare(profileView.TABLE_NOTE.order(profileView.NOTE_ID.desc).limit(1))
            for n in notes {
                idNote = n[profileView.NOTE_ID]
            }
        } catch{
            print(error)
        }
        return idNote
    }
    
    func insertNoteObj() {
        let idNote = self.getLastInsertedNote()
        guard idNote != 0 else{return}
        for obj in selectedObject {
            let insert = profileView.TABLE_RELATION_OBJECT_NOTE.insert(profileView.NOTE_ID <- idNote, profileView.OBJECT_ID <- obj.id)
            do {
                try self.database.run(insert)
                print("note obj inserted")
            } catch {
                print (error)
            }
        }
    }
    func insertNoteBook() {
        let idNote = self.getLastInsertedNote()
        guard idNote != 0 else{return}
        for book in selectedBook {
            let insert = profileView.TABLE_RELATION_BOOK_NOTE.insert(profileView.NOTE_ID <- idNote, profileView.BOOK_ID <- book.id)
            do {
                try self.database.run(insert)
                print("note book inserted")
            } catch {
                print (error)
            }
        }
    }
}
