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
    var database:Connection!
    let profileView = ProfileViewController()
    var idBook = 0
    var book: Book = Book(name: "", author: "", date: "", description: "")

    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldAuthor: UILabel!
    @IBOutlet weak var fieldDate: UILabel!
    @IBOutlet weak var fieldDescription: UILabel!
    var relatedTagList: [Tag] = []
    @IBOutlet weak var tagTableView: UITableView!
    var relatedClassList: [Object] = []
    @IBOutlet weak var classTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editBook" {
            let destination = segue.destination as! EditBookViewController
            destination.idBook = self.idBook
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
            return self.relatedClassList.count
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
            cell.textLabel?.text = relatedTagList[indexPath.row].name
            return cell
        case self.classTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = relatedClassList[indexPath.row].name
            return cell
        default :
            let cell = tableView.dequeueReusableCell(withIdentifier: objIdentifier, for: indexPath)
            cell.textLabel?.text = relatedClassList[indexPath.row].name
            return cell
        }
    }
    func loadRelation() {
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
    }
    
}
