//
//  DetailObjectViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailObjectViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tagIdentifier = "relatedTag2Cls"
    let clsIdentifier = "relatedCls2Cls"
    let noteIdentifier = "relatedNote2Cls"
    var database:Connection!
    let profileView = ProfileViewController()
    var idObject = 0
    var object = Object(name: "", date: "", description: "", type: "")

    @IBOutlet weak var fieldType: UILabel!
    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldDate: UILabel!
    @IBOutlet weak var fieldDescription: UITextView!
    var relatedTagList:[Tag] = []
    @IBOutlet weak var tagTableView: UITableView!
    let sectionList = ["Class","Book"]
    var relatedBookList: [Book] = []
    var relatedObjectList: [Object] = []
    @IBOutlet weak var classTableView: UITableView!
    var relatedNoteList: [Note] = []
    @IBOutlet weak var noteTableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        loadRelation()
        self.reloadTable(table: tagTableView)
        self.reloadTable(table: classTableView)
        self.reloadTable(table: noteTableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
        //loadRelation()
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        self.classTableView.delegate = self
        self.classTableView.dataSource = self
        self.noteTableView.delegate = self
        self.noteTableView.dataSource = self
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
        self.fieldDate.text = self.object.date
        self.fieldDescription.text = self.object.description
        self.fieldType.text = "\(self.object.type.capitalized) :"
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editClass", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {if segue.identifier == "editClass" {
        let destination = segue.destination as! EditObjectViewController
        destination.idObject = self.idObject
        }
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
            return self.relatedTagList.count
        case self.classTableView:
            switch sectionList[section] {
            case "Class" :
                return self.relatedObjectList.count
            case "Book" :
                return self.relatedBookList.count
            default:
                return 0
            }
        case self.noteTableView:
            return self.relatedNoteList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView{
        case self.tagTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: tagIdentifier, for: indexPath)
            cell.textLabel?.text = relatedTagList[indexPath.row].name
            return cell
        case self.classTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: clsIdentifier, for: indexPath)
            switch self.sectionList[indexPath.section] {
            case "Class" :
                cell.textLabel?.text = relatedObjectList[indexPath.row].name
                return cell
            case "Book" :
                cell.textLabel?.text = relatedBookList[indexPath.row].name
                return cell
            default :
                cell.textLabel?.text = relatedBookList[indexPath.row].name
                return cell
            }
        case self.noteTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: noteIdentifier, for: indexPath)
            cell.textLabel?.text = relatedNoteList[indexPath.row].title
            return cell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: noteIdentifier, for: indexPath)
            cell.textLabel?.text = relatedNoteList[indexPath.row].title
            return cell
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch tableView{
        case self.tagTableView:
            return 1
        case self.classTableView:
            return 2
        case self.noteTableView:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            switch tableView{
            case self.tagTableView:
                return "Tags"
            case self.classTableView:
                return "\(self.sectionList[section])"
            case self.noteTableView:
                return "Notes"
            default:
                return ""
            }
    }
    func loadRelation() {
        self.relatedNoteList = []
        self.relatedTagList = []
        self.relatedBookList = []
        self.relatedObjectList = []
        let objId = self.object.id
        var listIdNote: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_NOTE.filter(profileView.OBJECT_ID==objId))
            for i in ids {
                listIdNote.append(i[profileView.NOTE_ID])
            }
        } catch{
            print(error)
        }
        do {
            let notes = try self.database.prepare(profileView.TABLE_NOTE.filter(listIdNote.contains(profileView.NOTE_ID)))
            for n in notes {
                let note = Note(title: "", content: "", date_create: "", date_edit: "")
                note.id = n[profileView.NOTE_ID]
                note.title = n[profileView.NOTE_TITLE]
                note.content = n[profileView.NOTE_CONTENT]
                note.date_create = n[profileView.NOTE_CREATE_DATE]
                note.date_edit = n[profileView.NOTE_EDIT_DATE]
                self.relatedNoteList.append(note)
            }
        } catch{
            print(error)
        }
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
                self.relatedObjectList.append(obj)
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
                self.relatedTagList.append(tag)
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
                self.relatedBookList.append(bk)
            }
        } catch{
            print(error)
        }
    }
    func reloadTable(table tableView: UITableView){
        tableView.reloadData()
        tableView.layoutSubviews()
        tableView.layoutIfNeeded()
    }
}
