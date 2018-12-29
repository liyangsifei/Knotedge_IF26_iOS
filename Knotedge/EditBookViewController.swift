//
//  EditBookViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditBookViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let tagIdentifier = "editTag2Book"
    let classIdentifier = "editCls2Book"
    var database:Connection!
    let profileView = ProfileViewController()
    var idBook = 0
    var book = Book(name: "", author: "", date: "", description: "")

    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldAuthor: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var tagList: [Tag] = []
    var objectList: [Object] = []
    var selectedTag: [Tag] = []
    var selectedObject: [Object] = []
    @IBOutlet weak var tagTableView: UITableView!
    @IBOutlet weak var classTableView: UITableView!
    
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
    var dateSelected = Date()
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
        self.datePicker.isHidden = true
    }
    func loadDetails() {
        do {
            let books = Array(try self.database.prepare(profileView.TABLE_BOOK.filter(profileView.BOOK_ID == self.idBook)))
            for b in books {
                if b[profileView.BOOK_ID] == self.idBook {
                    self.book.id = b[profileView.BOOK_ID]
                    self.book.name = b[profileView.BOOK_NAME]
                    self.book.author = b[profileView.BOOK_AUTHOR]
                    self.book.date = b[profileView.BOOK_DATE]
                    self.book.description = b[profileView.BOOK_DESCRIPTION]
                }
            }
        } catch{
            print(error)
        }
        self.fieldName.text = self.book.name
        self.fieldAuthor.text = self.book.author
        self.btnDate.setTitle(self.book.date, for: .normal)
        self.fieldDescription.text = self.book.description
    }
    
    @IBAction func clickBtnDate(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.date = self.dateSelected
    }
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        self.btnDate.setTitle(formatter.string(from: datePicker.date), for: UIControl.State.normal)
        self.dateSelected = datePicker.date
    }
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateBook()
        updateRelation()
    }
    
    func updateBook() {
        let sql = profileView.TABLE_BOOK.filter(profileView.BOOK_ID == self.idBook)
        let newName = fieldName.text!
        let newAuthor = fieldAuthor.text!
        let newDate = btnDate.titleLabel!.text!
        let newDescription = fieldDescription.text!
        do {
            try self.database.run(sql.update(profileView.BOOK_NAME <- newName))
            try self.database.run(sql.update(profileView.BOOK_AUTHOR <- newAuthor))
            try self.database.run(sql.update(profileView.BOOK_DATE <- newDate))
            try self.database.run(sql.update(profileView.BOOK_DESCRIPTION <- newDescription))
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView{
        case self.tagTableView:
            return self.tagList.count
        case self.classTableView:
            return self.objectList.count
        default:
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView{
        case self.tagTableView:
            return 1
        case self.classTableView:
            return 1
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
            let cell = tableView.dequeueReusableCell(withIdentifier: classIdentifier, for: indexPath)
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
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: classIdentifier, for: indexPath)
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
        default :
            break
        }
    }
    
    func loadRelation() {
        loadSelectedRelation()
        loadAllRelation()
    }
    
    func loadSelectedRelation() {
        let bookId = self.book.id
        var listIdObj: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_BOOK.filter(profileView.BOOK_ID==bookId))
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
                print("relationf ound")
            }
        } catch{
            print(error)
        }
        var listIdTag: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_BOOK_TAG.filter(profileView.BOOK_ID==bookId))
            for i in ids {
                listIdTag.append(i[profileView.TAG_ID])
            }
        } catch{
            print(error)
        }
        do {
            let objects = try self.database.prepare(profileView.TABLE_TAG.filter(listIdTag.contains(profileView.TAG_ID)))
            for o in objects {
                let tag = Tag(name: "")
                tag.id = o[profileView.TAG_ID]
                tag.name = o[profileView.TAG_NAME]
                self.selectedTag.append(tag)
                
                print("relationf ound")
            }
        } catch{
            print(error)
        }
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
            let list = try self.database.prepare(profileView.TABLE_OBJECT)
            for item in list {
                let obj = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: item[profileView.OBJECT_TYPE])
                obj.id = item[profileView.OBJECT_ID]
                self.objectList.append(obj)
            }
        } catch{
            print(error)
        }
    }
    func updateRelation() {
        
    }
}
