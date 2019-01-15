//
//  EditObjectViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditObjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tagIdentifier = "editTag2Cls"
    let clsIdentifier = "editCls2Cls"
    var database: Connection!
    let profileView = ProfileViewController()
    var idObject = 0
    var object = Object(name: "", date: "", description: "", type: "")
    
    @IBOutlet weak var fieldType: UILabel!
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var fieldDescription: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var dateSelected = Date()
    var bookList: [Book] = []
    var objectList: [Object] = []
    var tagList: [Tag] = []
    var selectedBook: [Book] = []
    var selectedObject: [Object] = []
    var selectedTag: [Tag] = []
    let sectionList = ["Class","Book"]
    @IBOutlet weak var classTableView: UITableView!
    @IBOutlet weak var tagTableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
        loadRelation()
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        self.classTableView.delegate = self
        self.classTableView.dataSource = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
        self.datePicker.isHidden = true
    }
    
    @IBAction func chooseDate(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.date = self.dateSelected
    }
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.btnDate.setTitle(formatter.string(from: datePicker.date), for: UIControl.State.normal)
        self.dateSelected = datePicker.date
    }
    
    func loadDetails() {
        do {
            let objects = Array(try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)))
            for o in objects {
                if o[profileView.OBJECT_ID] == self.idObject {
                    self.object.id = o[profileView.OBJECT_ID]
                    self.object.name = o[profileView.OBJECT_NAME]
                    self.object.date = o[profileView.OBJECT_DATE]
                    self.object.description = o[profileView.OBJECT_DESCRIPTION]
                    self.object.type = o[profileView.OBJECT_TYPE]
                }
            }
        } catch{
            print(error)
        }
        self.fieldName.text = self.object.name
        self.btnDate.setTitle(self.object.date, for: .normal)
        self.fieldDescription.text = self.object.description
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateObject()
        updateRelation()
    }
    
    func updateObject() {
        let sql = profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)
        let newName = fieldName.text!
        let newDate = btnDate.titleLabel!.text!
        let newDescription = fieldDescription.text!
        do {
            try self.database.run(sql.update(profileView.OBJECT_NAME <- newName))
            try self.database.run(sql.update(profileView.OBJECT_DATE <- newDate))
            try self.database.run(sql.update(profileView.OBJECT_DESCRIPTION <- newDescription))
        } catch {
            print(error)
        }
    }
    //Listeners of the keyboard Event
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)/2
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
        switch tableView{
        case self.tagTableView:
            return 1
        case self.classTableView:
            return 2
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            switch tableView{
            case self.tagTableView:
                return "Tag"
            case self.classTableView:
                return "\(self.sectionList[section])"
            default:
                return ""
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case self.tagTableView:
            return self.tagList.count
        case self.classTableView:
            switch sectionList[section] {
            case "Class" :
                return self.objectList.count
            case "Book" :
                return self.bookList.count
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView{
        case self.tagTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: tagIdentifier, for: indexPath)
            cell.textLabel?.text = tagList[indexPath.row].name
            let hasItem = selectedTag.contains { (tag) -> Bool in
                if tag.id == tagList[indexPath.row].id {
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
        case self.classTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: clsIdentifier, for: indexPath)
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
                let hasItem = selectedBook.contains { (obj) -> Bool in
                    if obj.id == bookList[indexPath.row].id {
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
            default :
                cell.textLabel?.text = bookList[indexPath.row].name
                return cell
            }
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: clsIdentifier, for: indexPath)
            cell.textLabel?.text = objectList[indexPath.row].name
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch tableView {
        case self.tagTableView:
            var hasItem = -1
            for (index,value) in self.selectedTag.enumerated() {
                if value.id == tagList[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedTag.remove(at: hasItem)
            }else{
                selectedTag.append(tagList[indexPath.row])
            }
            self.tagTableView.reloadRows(at: [indexPath], with: .automatic)
        case self.classTableView:
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
            default:
                break
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
        do {
            let list = try self.database.prepare(profileView.TABLE_TAG)
            for item in list {
                let t = Tag(name: item[profileView.TAG_NAME])
                t.id = item[profileView.TAG_ID]
                self.tagList.append(t)
            }
        } catch{
            print(error)
        }
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID != self.idObject))
            for item in list {
                let obj = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: item[profileView.OBJECT_TYPE])
                obj.id = item[profileView.OBJECT_ID]
                self.objectList.append(obj)
            }
        } catch{
            print(error)
        }
        do {
            let list = try self.database.prepare(profileView.TABLE_BOOK)
            for item in list {
                let book = Book(name: item[profileView.BOOK_NAME], author: item[profileView.BOOK_AUTHOR], date: item[profileView.BOOK_DATE], description: item[profileView.BOOK_DESCRIPTION])
                book.id = item[profileView.BOOK_ID]
                self.bookList.append(book)
            }
        } catch{
            print(error)
        }
    }
    func loadSelectedRelation() {
        let objId = self.object.id
        var listIdObj: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECTS.filter(profileView.RELATION_OBJ1==objId))
            for i in ids {
                listIdObj.append(i[profileView.RELATION_OBJ2])
            }
        } catch{
            print(error)
        }
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECTS.filter(profileView.RELATION_OBJ2==objId))
            for i in ids {
                listIdObj.append(i[profileView.RELATION_OBJ1])
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
        var listIdTag: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_TAG.filter(profileView.OBJECT_ID==objId))
            for i in ids {
                listIdTag.append(i[profileView.TAG_ID])
            }
        } catch{
            print(error)
        }
        do {
            let tags = try self.database.prepare(profileView.TABLE_TAG.filter(listIdTag.contains(profileView.TAG_ID)))
            for t in tags {
                let tag = Tag(name: "")
                tag.id = t[profileView.TAG_ID]
                tag.name = t[profileView.TAG_NAME]
                self.selectedTag.append(tag)
            }
        } catch{
            print(error)
        }
        var listIdBook: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_BOOK.filter(profileView.OBJECT_ID==objId))
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
        let delRelTags = profileView.TABLE_RELATION_OBJECT_TAG.filter(profileView.OBJECT_ID == self.idObject)
        let delRelObjs = profileView.TABLE_RELATION_OBJECT_BOOK.filter(profileView.OBJECT_ID == self.idObject)
        let delRelObjs1 = profileView.TABLE_RELATION_OBJECTS.filter(profileView.RELATION_OBJ1 == self.idObject)
        let delRelObjs2 = profileView.TABLE_RELATION_OBJECTS.filter(profileView.RELATION_OBJ2 == self.idObject)
        do {
            try self.database.run(delRelTags.delete())
            try self.database.run(delRelObjs.delete())
            try self.database.run(delRelObjs1.delete())
            try self.database.run(delRelObjs2.delete())
        } catch {
            print(error)
        }
        for tag in selectedTag {
            let insert = profileView.TABLE_RELATION_OBJECT_TAG.insert(profileView.TAG_ID <- tag.id, profileView.OBJECT_ID <- self.idObject)
            do {
                try self.database.run(insert)
            } catch {
                print (error)
            }
        }
        for obj in selectedObject {
            let insert = profileView.TABLE_RELATION_OBJECTS.insert(profileView.RELATION_OBJ1 <- obj.id, profileView.RELATION_OBJ2 <- self.idObject)
            do {
                try self.database.run(insert)
            } catch {
                print (error)
            }
        }
        for obj in selectedBook {
            let insert = profileView.TABLE_RELATION_OBJECT_BOOK.insert(profileView.BOOK_ID <- obj.id, profileView.OBJECT_ID <- self.idObject)
            do {
                try self.database.run(insert)
            } catch {
                print (error)
            }
        }
    }
}
