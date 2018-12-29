//
//  AllNotesTableViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 28/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

private let reuseIdentifier = "noteCell"

class AllNotesTableViewController: UITableViewController {

    var database:Connection!
    let profileView = ProfileViewController()
    var noteList: [Note] = []
    var idNoteSelected = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadAllNotes()

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
        return self.noteList.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.idNoteSelected = noteList[indexPath.row].id
        performSegue(withIdentifier: "detailNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = noteList[indexPath.row].title
        cell.detailTextLabel?.text = noteList[indexPath.row].content

        return cell
    }
    
    func loadAllNotes() {
        do {
            let notes = try self.database.prepare(profileView.TABLE_NOTE)
            for item in notes {
                let t = Note(title: item[profileView.NOTE_TITLE], content: item[profileView.NOTE_CONTENT], date_create: item[profileView.NOTE_CREATE_DATE], date_edit: item[profileView.NOTE_EDIT_DATE])
                t.id = item[profileView.NOTE_ID]
                self.noteList.append(t)
            }
        } catch{
            print(error)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete?"
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    func deleteNote(id: Int) {
        let del = profileView.TABLE_NOTE.filter(profileView.NOTE_ID == id)
        do {
            try self.database.run(del.delete())
        } catch {
            print(error)
        }
        self.noteList = []
        loadAllNotes()
    }
    func delectNoteRelations(id: Int) {
        let delRelBoks = profileView.TABLE_RELATION_BOOK_NOTE.filter(profileView.NOTE_ID == id)
        let delRelObjs = profileView.TABLE_RELATION_OBJECT_NOTE.filter(profileView.NOTE_ID == id)
        do {
            try self.database.run(delRelBoks.delete())
            try self.database.run(delRelObjs.delete())
        } catch {
            print(error)
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delectNoteRelations(id: noteList[indexPath.row].id)
            deleteNote(id: noteList[indexPath.row].id)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
 

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailNote" {
            let destination = segue.destination as! DetailNoteViewController
            destination.idNote = self.idNoteSelected
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
