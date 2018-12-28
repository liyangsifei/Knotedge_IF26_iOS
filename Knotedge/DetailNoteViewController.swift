//
//  DetailNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailNoteViewController: UIViewController {
    
    var database:Connection!
    let profileView = ProfileViewController()
    var idNote = 0
    var note = Note(title: "", content: "", date_create: "", date_edit: "")

    @IBOutlet weak var fieldTitle: UILabel!
    @IBOutlet weak var fieldText: UILabel!
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

}
