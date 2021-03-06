//
//  DetailBookViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailBookViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let tagIdentifier = "relatedTag2Bk"
    let objIdentifier = "relatedCls2Bk"
    let noteIdentifier = "relatedNote2Book"
    var database:Connection!
    let profileView = ProfileViewController()
    var idBook = 0
    var book: Book = Book(name: "", author: "", date: "", description: "")
    var idNote = 0

    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldAuthor: UILabel!
    @IBOutlet weak var fieldDate: UILabel!
    @IBOutlet weak var fieldDescription: UITextView!
    var relatedTagList: [Tag] = []
    @IBOutlet weak var tagTableView: UITableView!
    var relatedClassList: [Object] = []
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
        self.fieldDate.text = self.book.date
        self.fieldDescription.text = self.book.description
    }
    
    @IBAction func editAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editBook", sender: self)
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
            return self.relatedClassList.count
        case self.noteTableView:
            return self.relatedNoteList.count
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
                return "Classes"
            case self.noteTableView:
                return "Notes"
            default:
                return ""
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView{
        case self.tagTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: tagIdentifier, for: indexPath)
            cell.textLabel?.text = relatedTagList[indexPath.row].name
            return cell
        case self.classTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = relatedClassList[indexPath.row].name
            return cell
        case self.noteTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: noteIdentifier, for: indexPath)
            cell.textLabel?.text = relatedNoteList[indexPath.row].title
            return cell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = relatedClassList[indexPath.row].name
            return cell
        }
    }
    func loadRelation() {
        self.relatedTagList = []
        self.relatedNoteList = []
        self.relatedClassList = []
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
                self.relatedClassList.append(obj)
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
                self.relatedTagList.append(tag)
            }
        } catch{
            print(error)
        }
        var listIdNote: [Int] = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_BOOK_NOTE.filter(profileView.BOOK_ID==bookId))
            for i in ids {
                listIdNote.append(i[profileView.NOTE_ID])
            }
        } catch{
            print(error)
        }
        do {
            let objects = try self.database.prepare(profileView.TABLE_NOTE.filter(listIdNote.contains(profileView.NOTE_ID)))
            for o in objects {
                let note = Note(title: "", content: "", date_create: "", date_edit: "")
                note.id = o[profileView.NOTE_ID]
                note.title = o[profileView.NOTE_TITLE]
                note.content = o[profileView.NOTE_CONTENT]
                note.date_create = o[profileView.NOTE_CREATE_DATE]
                note.date_edit = o[profileView.NOTE_EDIT_DATE]
                self.relatedNoteList.append(note)
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case self.noteTableView :
            self.idNote = relatedNoteList[indexPath.row].id
            performSegue(withIdentifier: "detailNote", sender: self)
        default:
            break
        }
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editBook" {
            let destination = segue.destination as! EditBookViewController
            destination.idBook = self.idBook
        } else if segue.identifier == "detailNote" {
            let destination = segue.destination as! DetailNoteViewController
            destination.idNote = self.idNote
        }
    }
}
