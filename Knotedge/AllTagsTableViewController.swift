//
//  AllTagsTableViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 28/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

private let reuseIdentifier = "tagCell"

class AllTagsTableViewController: UITableViewController {
    
    var database:Connection!
    let profileView = ProfileViewController()
    var selectedTagId = 0
    var tagList: [Tag] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadAllTags() 

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
        return self.tagList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        cell.textLabel?.text = tagList[indexPath.row].name
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 
    func deleteTag(id: Int) {
        let del = profileView.TABLE_TAG.filter(profileView.TAG_ID == id)
        do {
            try self.database.run(del.delete())
        } catch {
            print(error)
        }
        tagList = []
        loadAllTags()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTagId = tagList[indexPath.row].id
        let controller = UIAlertController(title: "Modify Tag", message: "", preferredStyle: UIAlertController.Style.alert)
        var inputText: UITextField = UITextField();
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            action in controller.dismiss(animated: true, completion: nil)
            self.updateTag(name: inputText.text!)
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            action in controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.addTextField { (textField) in
            inputText = textField
            inputText.text = self.tagList[indexPath.row].name
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func updateTag(name: String) {
        let sql = profileView.TABLE_TAG.filter(profileView.TAG_ID == self.selectedTagId)
        do {
            try self.database.run(sql.update(profileView.TAG_NAME <- name))
            self.tagList = []
            self.loadAllTags()
        } catch {
            print(error)
        }
    }

    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete?"
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let idDel = tagList[indexPath.row].id
            deleteTag(id: idDel)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    func loadAllTags() {
        do {
            let list = try self.database.prepare(profileView.TABLE_TAG)
            for item in list {
                let t = Tag(name: item[profileView.TAG_NAME])
                t.id = item[profileView.TAG_ID]
                self.tagList.append(t)
            }
        } catch{
            print(error)
        }
    }
    
    func addTag(name: String) {
        let insert = profileView.TABLE_TAG.insert(profileView.TAG_NAME <- name)
        do {
            try self.database.run(insert)
        } catch {
            print (error)
        }
        self.tagList = []
        self.loadAllTags()
    }
    
    @IBAction func addTagAction(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "New Tag", message: "", preferredStyle: UIAlertController.Style.alert)
        var inputText: UITextField = UITextField();
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            action in controller.dismiss(animated: true, completion: nil)
            self.addTag(name: inputText.text!)
            self.tableView.reloadData()
            //self.tableView.beginUpdates()
            //let indexPaths = [IndexPath(row: self.tagList.count-1, section: 1)]
            //self.tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.automatic)
            //self.tableView.endUpdates()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            action in controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        controller.addAction(cancelAction)
        controller.addTextField { (textField) in
            inputText = textField
            inputText.placeholder = "enter tag name"
        }
        self.present(controller, animated: true, completion: nil)
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
