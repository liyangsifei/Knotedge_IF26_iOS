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
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
    }
    var dateSelected = Date()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDetails()
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
        self.datePicker.isHidden = true
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
        self.btnDate.setTitle(self.book.date, for: .normal)
        self.fieldDescription.text = self.book.description
    }
    
    @IBAction func clickBtnDate(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.date = self.dateSelected
    }
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        self.btnDate.setTitle(formatter.string(from: datePicker.date), for: UIControl.State.normal)
        self.dateSelected = datePicker.date
    }
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateBook()
    }
    
    func updateBook() {
        let sql = profileView.TABLE_BOOK.filter(profileView.BOOK_ID == self.idBook)
        let newName = fieldName.text!
        let newAuthor = fieldAuthor.text!
        let newDate = btnDate.titleLabel!.text!
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
    
    //Listeners of the keyboard Event
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)/2
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
