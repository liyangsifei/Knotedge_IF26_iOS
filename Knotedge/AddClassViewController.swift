//
//  AddClassViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite
private var cellIdentifier = "tag2obj"
private var objIdentifier = "obj2obj"

class AddClassViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var database:Connection!
    let profileView = ProfileViewController()
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var fieldAuthor: UITextField!
    @IBOutlet weak var labelAuthor: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    var dateSelected = Date()
    var tagList:[Tag] = []
    var selectedTags: [Tag] = []
    @IBOutlet weak var tagTableView: UITableView!
    var selectedObjs: [Object] = []
    var objectList:[Object] = []
    var bookList:[Book] = []
    @IBOutlet weak var classTableView: UITableView!
    
    @IBOutlet weak var spaceBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        configureToolBar()
        loadAllTags()
        loadAllObjects()
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
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
        self.datePicker.isHidden = true
    }
    
    @IBAction func changeTypeAction(_ sender: UISegmentedControl) {
        switch self.typeSegment.selectedSegmentIndex {
        case 0:
            if self.fieldAuthor.isHidden {
                self.labelAuthor.isHidden = false
                self.fieldAuthor.isHidden = false
            }
        default:
            if !self.fieldAuthor.isHidden {
                self.fieldAuthor.isHidden = true
                self.labelAuthor.isHidden = true
            }
        }
    }
    
    func insertBook() {
        let name = fieldName.text!
        let author = fieldAuthor.text!
        let date = btnDate.titleLabel!.text!
        let description = fieldDescription.text!
        let insert = profileView.TABLE_BOOK.insert(profileView.BOOK_NAME <- name, profileView.BOOK_AUTHOR <- author, profileView.BOOK_DESCRIPTION <- description, profileView.BOOK_DATE <- date)
        do {
            try self.database.run(insert)
        } catch {
            print (error)
        }
    }
    
    func insertClass () {
        let name = fieldName.text!
        var type = ""
        let date = btnDate.titleLabel!.text!
        let description = fieldDescription.text!
        switch typeSegment.selectedSegmentIndex{
        case 1 :
            type = "person"
        case 2 :
            type = "event"
        case 3 :
            type = "place"
        case 4 :
            type = "object"
        default: break
        }
        let insert = profileView.TABLE_OBJECT.insert(profileView.OBJECT_NAME <- name, profileView.OBJECT_TYPE <- type, profileView.OBJECT_DESCRIPTION <- description, profileView.OBJECT_DATE <- date)
        do {
            try self.database.run(insert)
        } catch {
            print (error)
        }
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
    
    //Tool Bar
    @IBOutlet weak var cancelBarItem: UIBarButtonItem!
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    func configureToolBar () {
        let toolbarButtonItem = [cancelBarItem, spaceBarItem, addBarItem]
        toolBar.setItems(toolbarButtonItem as? [UIBarButtonItem], animated: true);
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "back2main", sender: self)
    }
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        switch typeSegment.selectedSegmentIndex {
        case 0:
            insertBook()
            insertBookTag()
            insertBookObj()
            performSegue(withIdentifier: "back2main", sender: self)
        default:
            insertClass()
            insertObjTag()
            insertObjObj()
            performSegue(withIdentifier: "back2main", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back2main" {
            _ = segue.destination as! MainTabBarController
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView{
        case self.tagTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            cell.textLabel?.text = tagList[indexPath.row].name
            let hasItem = selectedTags.contains { (tag) -> Bool in
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
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = objectList[indexPath.row].name
            let hasItem = selectedObjs.contains { (obj) -> Bool in
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
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = objectList[indexPath.row].name
            return cell
        }
    }
    
    func loadAllTags() {
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
    }
    func loadAllObjects() {
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        switch tableView {
        case self.tagTableView:
            var hasItem = -1
            for (index,value) in self.selectedTags.enumerated() {
                if value.id == tagList[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedTags.remove(at: hasItem)
            }else{
                selectedTags.append(tagList[indexPath.row])
            }
            self.tagTableView.reloadRows(at: [indexPath], with: .automatic)
        case self.classTableView:
            var hasItem = -1
            for (index,value) in self.selectedObjs.enumerated() {
                if value.id == objectList[indexPath.row].id {
                    hasItem = index
                }
            }
            if hasItem != -1 {
                selectedObjs.remove(at: hasItem)
            }else{
                selectedObjs.append(objectList[indexPath.row])
            }
            self.classTableView.reloadRows(at: [indexPath], with: .automatic)
        default :
            break
        }
    }
    
    func getLastInsertedBookId() -> Int {
        var idBook = 0
        do {
            let books = try self.database.prepare(profileView.TABLE_BOOK.order(profileView.BOOK_ID.desc).limit(1))
            for b in books {
                idBook = b[profileView.BOOK_ID]
            }
        } catch{
            print(error)
        }
        return idBook
    }
    func getLastInsertedObjId() -> Int {
        var idObj = 0
        do {
            let objs = try self.database.prepare(profileView.TABLE_OBJECT.order(profileView.OBJECT_ID.desc).limit(1))
            for o in objs {
                idObj = o[profileView.OBJECT_ID]
            }
        } catch{
            print(error)
        }
        return idObj
    }
    
    func insertBookTag() {
        let idBook = self.getLastInsertedBookId()
        guard idBook != 0 else{return}
        for tag in selectedTags {
            let insert = profileView.TABLE_RELATION_BOOK_TAG.insert(profileView.TAG_ID <- tag.id, profileView.BOOK_ID <- idBook)
            do {
                try self.database.run(insert)
                print("book tag inserted")
            } catch {
                print (error)
            }
        }
    }
    func insertBookObj() {
        let idBook = self.getLastInsertedBookId()
        guard idBook != 0 else{return}
        for obj in selectedObjs {
            let insert = profileView.TABLE_RELATION_OBJECT_BOOK.insert(profileView.OBJECT_ID <- obj.id, profileView.BOOK_ID <- idBook)
            do {
                try self.database.run(insert)
                print("book obj inserted")
            } catch {
                print (error)
            }
        }
    }
    func insertObjTag() {
        let idObj = self.getLastInsertedObjId()
        guard idObj != 0 else{return}
        for tag in selectedTags {
            let insert = profileView.TABLE_RELATION_OBJECT_TAG.insert(profileView.TAG_ID <- tag.id, profileView.OBJECT_ID <- idObj)
            do {
                try self.database.run(insert)
                print("obj tag inserted")
            } catch {
                print (error)
            }
        }
    }
    func insertObjObj() {
        let idObj = self.getLastInsertedObjId()
        guard idObj != 0 else{return}
        for obj in selectedObjs {
            let insert = profileView.TABLE_RELATION_OBJECTS.insert(profileView.RELATION_OBJ1 <- obj.id, profileView.RELATION_OBJ2 <- idObj)
            do {
                try self.database.run(insert)
                print("obj obj inserted")
            } catch {
                print (error)
            }
        }
    }
}
