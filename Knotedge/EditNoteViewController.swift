//
//  EditNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditNoteViewController: UIViewController {
    
    var database: Connection!
    let profileView = ProfileViewController()
    
    @IBOutlet weak var fieldTitle: UITextField!
    @IBOutlet weak var fieldText: UITextView!
    
    var idNote = 0
    var note = Note(title: "", content: "", date_create: "", date_edit: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    func loadDetails() {
        do {
            let notes = Array(try self.database.prepare(profileView.TABLE_NOTE.filter(profileView.NOTE_ID == self.idNote)))
            for n in notes {
                if n[profileView.NOTE_ID] == self.idNote {
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
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateNote()
    }
    
    func updateNote() {
        let date = NSDate()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let currentDate = dateFormat.string(from: date as Date) as String
        
        let sql = profileView.TABLE_NOTE.filter(profileView.NOTE_ID == self.idNote)
        let newTitle = fieldTitle.text!
        let newText = fieldText.text!
        do {
            try self.database.run(sql.update(profileView.NOTE_TITLE <- newTitle))
            try self.database.run(sql.update(profileView.NOTE_CONTENT <- newText))
            try self.database.run(sql.update(profileView.NOTE_EDIT_DATE <- currentDate))
        } catch {
            print(error)
        }
    }
    
    //Listeners of the keyboard Event
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)/4
    }
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
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
