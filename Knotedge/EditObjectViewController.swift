//
//  EditObjectViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditObjectViewController: UIViewController {
    
    var database: Connection!
    let profileView = ProfileViewController()
    var idObject = 0
    var object = Object(name: "", date: "", description: "", type: "")
    
    @IBOutlet weak var fieldType: UILabel!
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var btnDate: UIButton!
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    var dateSelected = Date()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
        self.datePicker.isHidden = true
    }
    
    @IBAction func chooseDate(_ sender: UIButton) {
        datePicker.isHidden = false
        datePicker.date = self.dateSelected
    }
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        self.btnDate.setTitle(formatter.string(from: datePicker.date), for: UIControl.State.normal)
        self.dateSelected = datePicker.date
    }
    
    func loadDetails() {
        do {
            let objects = Array(try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)))
            for o in objects {
                if o[profileView.OBJECT_ID] == self.idObject {
                    self.object.name = o[profileView.OBJECT_NAME]
                    self.object.date = o[profileView.OBJECT_DATE]
                    self.object.description = o[profileView.OBJECT_DESCRIPTION]
                }
            }
        } catch{
            print(error)
        }
        self.fieldName.text = self.object.name
        self.btnDate.setTitle(self.object.date, for: .normal)
        self.fieldDescription.text = self.object.description
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateObject()
    }
    
    func updateObject() {
        let sql = profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)
        let newName = fieldName.text!
        let newDate = btnDate.titleLabel!.text!
        let newDescription = fieldDescription.text!
        do {
            try self.database.run(sql.update(profileView.OBJECT_NAME <- newName))
            try self.database.run(sql.update(profileView.OBJECT_DATE <- newDate))
            try self.database.run(sql.update(profileView.OBJECT_DESCRIPTION <- newDescription))
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
