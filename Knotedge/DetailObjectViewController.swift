//
//  DetailObjectViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class DetailObjectViewController: UIViewController {
    
    var database:Connection!
    let profileView = ProfileViewController()
    var idObject = 0
    var object = Object(name: "", date: "", description: "", type: "")

    @IBOutlet weak var fieldType: UILabel!
    @IBOutlet weak var fieldName: UILabel!
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
            let objects = Array(try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_ID == self.idObject)))
            for o in objects {
                if o[profileView.OBJECT_ID] == self.idObject {
                    self.object.id = o[profileView.OBJECT_ID]
                    self.object.name = o[profileView.OBJECT_NAME]
                    self.object.date = o[profileView.OBJECT_DATE]
                    self.object.description = o[profileView.OBJECT_DESCRIPTION]
                    self.object.type = o[profileView.OBJECT_TYPE]
                }
            }
        } catch{
            print(error)
        }
        self.fieldName.text = self.object.name
        self.fieldDate.text = self.object.date
        self.fieldDescription.text = self.object.description
        self.fieldType.text = self.object.type
    }
    
    @IBAction func actionEdit(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "editClass", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {if segue.identifier == "editClass" {
        let destination = segue.destination as! EditObjectViewController
        destination.idObject = self.idObject
        print("detail:\(self.idObject)")
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
