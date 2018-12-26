//
//  AddNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class AddNoteViewController: UIViewController {

    var database: Connection!
    let profileView = ProfileViewController()
    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarItem: UIBarButtonItem!
    @IBOutlet weak var spaceBarItem: UIBarButtonItem!
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var textField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        configureToolBar()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    func insertNote() {
        let title = titleField.text!
        let content = textField.text!
        let date = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let currentDate = dateFormat.string(from: date as Date) as String
        
        let insert = profileView.TABLE_NOTE.insert(profileView.NOTE_TITLE <- title, profileView.NOTE_CONTENT <- content, profileView.NOTE_CREATE_DATE <- currentDate, profileView.NOTE_EDIT_DATE <- currentDate)
        do {
            try self.database.run(insert)
            print ("note inserted")
        } catch {
            print (error)
        }
    }
    
    
    
    func configureToolBar () {
        let toolbarButtonItem = [cancelBarItem, spaceBarItem, addBarItem]
        toolBar.setItems(toolbarButtonItem as? [UIBarButtonItem], animated: true);
    }
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
    }
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        insertNote()
    }
    
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
