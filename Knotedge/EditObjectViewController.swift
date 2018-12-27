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
    @IBOutlet weak var fieldDate: UITextField!
    @IBOutlet weak var fieldDescription: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadDetails()
        print("edit \(idObject)")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
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
        self.fieldDate.text = self.object.date
        self.fieldDescription.text = self.object.description
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        updateObject()
    }
    
    func updateObject() {
        let sql = profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)
        let newName = fieldName.text!
        let newDate = fieldDate.text!
        let newDescription = fieldDescription.text!
        do {
            try self.database.run(sql.update(profileView.OBJECT_NAME <- newName))
            try self.database.run(sql.update(profileView.OBJECT_DATE <- newDate))
            try self.database.run(sql.update(profileView.OBJECT_DESCRIPTION <- newDescription))
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
