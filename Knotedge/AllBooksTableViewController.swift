//
//  AllBooksTableViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

private let cellIdentifier = "bookCell"

class AllBooksTableViewController: UITableViewController {

    var database:Connection!
    let profileView = ProfileViewController()
    
    var bookList: [Book] = []
    var selectedBookId = 0
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //loadAllBooks()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadAllBooks()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.bookList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        cell.textLabel?.text = "\(self.bookList[indexPath.row].name)"
        cell.detailTextLabel?.text = "\(self.bookList[indexPath.row].author)"

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedBookId = bookList[indexPath.row].id
        performSegue(withIdentifier: "detailBook", sender: self)
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let idDel = self.bookList[indexPath.row].id
            deleteBookRel(id: idDel)
            deleteBook(id: idDel)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete?"
    }

    func deleteBook(id: Int) {
        let del = profileView.TABLE_BOOK.filter(profileView.BOOK_ID == id)
        do {
            try self.database.run(del.delete())
        } catch {
            print(error)
        }
        bookList = []
        loadAllBooks()
    }
    func deleteBookRel(id: Int) {
        let delRelTags = profileView.TABLE_RELATION_BOOK_TAG.filter(profileView.BOOK_ID == id)
        let delRelObjs = profileView.TABLE_RELATION_OBJECT_BOOK.filter(profileView.BOOK_ID == id)
        do {
            try self.database.run(delRelTags.delete())
            try self.database.run(delRelObjs.delete())
        } catch {
            print(error)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailBook" {
            let destination = segue.destination as! DetailBookViewController
            destination.idBook = self.selectedBookId
        }
    }
    
    func loadAllBooks() {
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
