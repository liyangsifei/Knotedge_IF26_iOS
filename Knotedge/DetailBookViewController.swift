//
//  DetailBookViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailBookViewController: UIViewController {
    
    var database:Connection!
    let profileView = ProfileViewController()
    var idBook = 0
    var book: Book = Book(name: "", author: "", date: "", description: "")

    @IBOutlet weak var fieldName: UILabel!
    @IBOutlet weak var fieldAuthor: UILabel!
    @IBOutlet weak var fieldDate: UILabel!
    @IBOutlet weak var fieldDescription: UILabel!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
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
}
