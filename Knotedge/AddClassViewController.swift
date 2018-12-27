//
//  AddClassViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class AddClassViewController: UIViewController, UIScrollViewDelegate {

    var database:Connection!
    let profileView = ProfileViewController()
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var typeSegment: UISegmentedControl!
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var fieldDate: UITextField!
    @IBOutlet weak var fieldAuthor: UITextField!
    @IBOutlet weak var labelAuthor: UILabel!
    
    @IBOutlet weak var spaceBarItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        configureToolBar()
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
    
    @IBAction func changeTypeAction(_ sender: UISegmentedControl) {
        switch self.typeSegment.selectedSegmentIndex {
        case 0:
            if self.fieldAuthor.isHidden {
                self.labelAuthor.isHidden = false
                self.fieldAuthor.isHidden = false
            }
        default:
            if !self.fieldAuthor.isHidden {
                self.fieldAuthor.isHidden = true
                self.labelAuthor.isHidden = true
            }
        }
    }
    
    func insertBook() {
        let name = fieldName.text!
        let author = fieldAuthor.text!
        let date = fieldDate.text!
        let description = fieldDescription.text!
        let insert = profileView.TABLE_BOOK.insert(profileView.BOOK_NAME <- name, profileView.BOOK_AUTHOR <- author, profileView.BOOK_DESCRIPTION <- description, profileView.BOOK_DATE <- date)
        do {
            try self.database.run(insert)
            print ("book inserted")
        } catch {
            print (error)
        }
    }
    
    func insertClass () {
        let name = fieldName.text!
        var type = ""
        let date = fieldDate.text!
        let description = fieldDescription.text!
        switch typeSegment.selectedSegmentIndex{
        case 1 :
            type = "person"
        case 2 :
            type = "event"
        case 3 :
            type = "place"
        case 4 :
            type = "object"
        default: break
        }
        let insert = profileView.TABLE_OBJECT.insert(profileView.OBJECT_NAME <- name, profileView.OBJECT_TYPE <- type, profileView.OBJECT_DESCRIPTION <- description, profileView.OBJECT_DATE <- date)
        do {
            try self.database.run(insert)
            print ("class inserted")
        } catch {
            print (error)
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
    
    //Tool Bar
    @IBOutlet weak var cancelBarItem: UIBarButtonItem!
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    func configureToolBar () {
        let toolbarButtonItem = [cancelBarItem, spaceBarItem, addBarItem]
        toolBar.setItems(toolbarButtonItem as? [UIBarButtonItem], animated: true);
    }
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "back2main", sender: self)
    }
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        print("add action")
        switch typeSegment.selectedSegmentIndex {
        case 0:
            insertBook()
            performSegue(withIdentifier: "back2main", sender: self)
        default:
            insertClass()
            performSegue(withIdentifier: "back2main", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "back2main" {
            _ = segue.destination as! MainTabBarController
        }
    }
}
