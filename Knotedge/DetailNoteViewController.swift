//
//  DetailNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailNoteViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    let cellIdentifier = "relatedCls2Note"
    var database:Connection!
    let profileView = ProfileViewController()
    var idNote = 0
    var note = Note(title: "", content: "", date_create: "", date_edit: "")

    @IBOutlet weak var fieldTitle: UILabel!
    @IBOutlet weak var fieldText: UITextView!
    @IBOutlet weak var fieldTime: UILabel!
    var relatedObjectList: [Object] = []
    var relatedBookList: [Book] = []
    let sectionList = ["Class","Book"]
    @IBOutlet weak var classTableView: UITableView!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        loadRelatedClass()
        self.reloadTable(table: classTableView)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
        //loadRelatedClass()
        classTableView.dataSource = self
        classTableView.delegate = self
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
        self.fieldTime.text = self.note.date_edit
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editNote", sender: self)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNote" {
        let destination = segue.destination as! EditNoteViewController
        destination.idNote = self.idNote
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
            return self.relatedObjectList.count
        case "Book" :
            return self.relatedBookList.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch self.sectionList[indexPath.section] {
        case "Class" :
            cell.textLabel?.text = relatedObjectList[indexPath.row].name
            return cell
        case "Book" :
            cell.textLabel?.text = relatedBookList[indexPath.row].name
            return cell
        default:
            return cell
        }
    }
    
    func loadRelatedClass() {
        self.relatedObjectList = []
        self.relatedBookList = []
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
                self.relatedObjectList.append(obj)
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
