//
//  EditBookViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditBookViewController: UIViewController {
    
    var database:Connection!
    let profileView = ProfileViewController()
    var idBook = 0
    var book = Book(name: "", author: "", date: "", description: "")

    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldAuthor: UITextField!
    @IBOutlet weak var fieldDate: UITextField!
    @IBOutlet weak var fieldDescription: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    func loadDetails() {
        do {
            let books = Array(try self.database.prepare(profileView.TABLE_BOOK.filter(profileView.BOOK_ID == self.idBook)))
            for b in books {
                if b[profileView.BOOK_ID] == self.idBook {
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
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateBook()
    }
    
    func updateBook() {
        let sql = profileView.TABLE_BOOK.filter(profileView.BOOK_ID == self.idBook)
        let newName = fieldName.text!
        let newAuthor = fieldAuthor.text!
        let newDate = fieldDate.text!
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
}
