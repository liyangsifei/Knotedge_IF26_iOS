//
//  AllClassesTableViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class AllClassesTableViewController: UITableViewController {
    
    let cellIdentifier = "classCell"
    
    let PERSON = "Person"
    let EVENT = "Event"
    let OBJECT = "Object"
    let PLACE = "Place"

    var database:Connection!
    let profileView = ProfileViewController()
    let typeSection = ["Person","Event","Place","Object"]
    
    var personList: [Person] = []
    var eventList: [Event] = []
    var placeList: [Place] = []
    var objectList: [Object] = []
    var allClassList: [Object] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadAllClasses()
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) ->
        String? {
            return "\(self.typeSection[section])"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch typeSection[section] {
        case self.PERSON :
            return self.personList.count
        case self.EVENT :
            return self.eventList.count
        case self.PLACE :
            return self.placeList.count
        case self.OBJECT :
            return self.objectList.count
        default:
            return 0
        }
    }
    /*
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allClassList.count
    }*/
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "classCell", for: indexPath)
        switch typeSection[indexPath.section] {
        case self.PERSON :
            cell.textLabel?.text = "\(self.personList[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(self.personList[indexPath.row].description)"
            break
        case self.EVENT :
            cell.textLabel?.text = "\(self.eventList[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(self.eventList[indexPath.row].description)"
            break
        case self.PLACE :
            cell.textLabel?.text = "\(self.placeList[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(self.placeList[indexPath.row].description)"
            break
        case self.OBJECT :
            cell.textLabel?.text = "\(self.objectList[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(self.objectList[indexPath.row].description)"
            break
        default :
            cell.textLabel?.text = "\(self.objectList[indexPath.row].name)"
            cell.detailTextLabel?.text = "\(self.objectList[indexPath.row].description)"
            break
        }
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func loadAllClasses() {
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT)
            var type = ""
            for item in list {
                type = item[profileView.OBJECT_TYPE]
                switch type {
                case "person" :
                    let p = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "person")
                    p.id = item[profileView.OBJECT_ID]
                    self.personList.append(p)
                    self.allClassList.append(p)
                    break
                case "event" :
                    let e = Event(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "event")
                    e.id = item[profileView.OBJECT_ID]
                    self.eventList.append(e)
                    self.allClassList.append(e)
                    break
                case "place" :
                    let p = Place(name: item[profileView.OBJECT_NAME], date: "", description: item[profileView.OBJECT_DESCRIPTION], type: "place")
                    p.id = item[profileView.OBJECT_ID]
                    self.placeList.append(p)
                    self.allClassList.append(p)
                    break
                case "object" :
                    let o = Object(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "object")
                    o.id = item[profileView.OBJECT_ID]
                    self.objectList.append(o)
                    self.allClassList.append(o)
                    break
                default :
                    break
                }
            }
        } catch{
            print(error)
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
