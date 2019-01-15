//
//  ViewByViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 06/01/2019.
//  Copyright © 2019 if26. All rights reserved.
//

import UIKit
import SQLite
private var cellIdentifier = "relatedClassCell"

class ViewByViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource  {
    

    var database:Connection!
    let profileView = ProfileViewController()
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var tagPicker: UIPickerView!
    
    var allTagList: [Tag] = []
    var tagSelected = Tag(name: "")
    var types = ["All Objects","Book","Person","Event","Place","Object"]
    var orderSelected = 0
    var orders = ["Time","A-Z","Z-A"]
    var typeSelected = 0
    var classList : [Object] = []
    var bookList: [Book] = []
    var personList : [Person] = []
    var eventList : [Event] = []
    var placeList : [Place] = []
    var objectList : [Object] = []
    var objIdList: [Int] = []
    var bookIdList: [Int] = []
    
    var selectedObjId = 0
    var selectedBookId = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        
        self.table.delegate = self
        self.table.dataSource = self
        
        self.tagPicker.delegate = self
        self.tagPicker.dataSource = self
        loadAllTags()
        initTagSelect()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAllTags()
        reloadTable()
        self.tagPicker.reloadAllComponents()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
        self.tagPicker.isHidden = true
    }
    
    func loadAllTags() {
        self.allTagList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_TAG)
            for item in list {
                let t = Tag(name: item[profileView.TAG_NAME])
                t.id = item[profileView.TAG_ID]
                self.allTagList.append(t)
            }
        } catch{
            print(error)
        }
    }
    func initTagSelect(){
        if(allTagList.count > 0){
            self.tagSelected = allTagList[0]
            self.reloadTableTagChanged()
        }
    }
    
    func reloadTableTagChanged() {
        self.loadAllRelatedObjId()
        self.loadAllRelatedBookId()
        loadAllClassesByTag()
        loadAllBooksByTag()
        loadAllPersonsByTag()
        loadAllEventsByTag()
        loadAllPlacesByTag()
        loadAllObjectsByTag()
        self.reloadTable()
        
    }
    
    func reloadTable(){
        self.table.reloadData()
        self.table.layoutSubviews()
        self.table.layoutIfNeeded()
    }
    
    func reloadTableOrderChanged() {
        switch self.orderSelected {
        case 0:
            self.classList = self.classList.sorted(by: { $0.date > $1.date})
            self.bookList = self.bookList.sorted(by: { $0.date > $1.date})
            self.personList = self.personList.sorted(by: { $0.date > $1.date})
            self.eventList = self.eventList.sorted(by: { $0.date > $1.date})
            self.placeList = self.placeList.sorted(by: { $0.date > $1.date})
            self.objectList = self.objectList.sorted(by: { $0.date > $1.date})
        case 1:
            self.classList = self.classList.sorted(by: { $0.name < $1.name})
            self.bookList = self.bookList.sorted(by: { $0.name < $1.name})
            self.personList = self.personList.sorted(by: { $0.name < $1.name})
            self.eventList = self.eventList.sorted(by: { $0.name < $1.name})
            self.placeList = self.placeList.sorted(by: { $0.name < $1.name})
            self.objectList = self.objectList.sorted(by: { $0.name < $1.name})
        default:
            self.classList = self.classList.sorted(by: { $0.name > $1.name})
            self.bookList = self.bookList.sorted(by: { $0.name > $1.name})
            self.personList = self.personList.sorted(by: { $0.name > $1.name})
            self.eventList = self.eventList.sorted(by: { $0.name > $1.name})
            self.placeList = self.placeList.sorted(by: { $0.name > $1.name})
            self.objectList = self.objectList.sorted(by: { $0.name > $1.name})
        }
        self.table.reloadData()
        self.table.layoutSubviews()
        self.table.layoutIfNeeded()
    }
    
    func loadAllRelatedObjId(){
        self.objIdList = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_OBJECT_TAG.filter(profileView.TAG_ID==self.tagSelected.id))
            for i in ids {
                self.objIdList.append(i[profileView.OBJECT_ID])
            }
        } catch{
            print(error)
        }
    }
    
    func loadAllRelatedBookId(){
        self.bookIdList = []
        do {
            let ids = try self.database.prepare(profileView.TABLE_RELATION_BOOK_TAG.filter(profileView.TAG_ID==self.tagSelected.id))
            for i in ids {
                self.bookIdList.append(i[profileView.BOOK_ID])
            }
        } catch{
            print(error)
        }
    }
    
    func loadAllClassesByTag(){
        self.classList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(self.objIdList.contains(profileView.OBJECT_ID)))
            for item in list {
                let p = Object(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: item[profileView.OBJECT_TYPE])
                p.id = item[profileView.OBJECT_ID]
                self.classList.append(p)
            }
        } catch{
            print(error)
        }
    }
    func loadAllBooksByTag(){
        self.bookList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_BOOK.filter(self.bookIdList.contains(profileView.BOOK_ID)))
            for item in list {
                let b = Book(name: item[profileView.BOOK_NAME], author: item[profileView.BOOK_AUTHOR], date: item[profileView.BOOK_DATE], description: item[profileView.BOOK_DESCRIPTION])
                b.id = item[profileView.BOOK_ID]
                self.bookList.append(b)
            }
        } catch{
            print(error)
        }
    }
    func loadAllPersonsByTag(){
        self.personList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_TYPE=="person").filter(self.objIdList.contains(profileView.OBJECT_ID)))
            for item in list {
                let p = Person(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "person")
                p.id = item[profileView.OBJECT_ID]
                self.personList.append(p)
            }
        } catch{
            print(error)
        }
    }
    func loadAllEventsByTag(){
        self.eventList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_TYPE=="event").filter(self.objIdList.contains(profileView.OBJECT_ID)))
            for item in list {
                let e = Event(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "event")
                e.id = item[profileView.OBJECT_ID]
                self.eventList.append(e)
            }
        } catch{
            print(error)
        }
    }
    func loadAllPlacesByTag(){
        self.placeList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_TYPE=="place").filter(self.objIdList.contains(profileView.OBJECT_ID)))
            for item in list {
                let p = Place(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "place")
                p.id = item[profileView.OBJECT_ID]
                self.placeList.append(p)
            }
        } catch{
            print(error)
        }
    }
    func loadAllObjectsByTag(){
        self.objectList = []
        do {
            let list = try self.database.prepare(profileView.TABLE_OBJECT.filter(profileView.OBJECT_TYPE=="object").filter(self.objIdList.contains(profileView.OBJECT_ID)))
            for item in list {
                let o = Object(name: item[profileView.OBJECT_NAME], date: item[profileView.OBJECT_DATE], description: item[profileView.OBJECT_DESCRIPTION], type: "object")
                o.id = item[profileView.OBJECT_ID]
                self.objectList.append(o)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.typeSelected {
        case 0:
            return self.classList.count
        case 1:
            return self.bookList.count
        case 2:
            return self.personList.count
        case 3:
            return self.eventList.count
        case 4:
            return self.placeList.count
        case 5:
            return self.objectList.count
        default:
            return self.classList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        switch self.typeSelected {
        case 0:
            cell.textLabel?.text = self.classList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.classList[indexPath.row].date)
        case 1:
            cell.textLabel?.text = self.bookList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.bookList[indexPath.row].date)
        case 2:
            cell.textLabel?.text = self.personList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.personList[indexPath.row].date)
        case 3:
            cell.textLabel?.text = self.eventList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.eventList[indexPath.row].date)
        case 4:
            cell.textLabel?.text = self.placeList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.placeList[indexPath.row].date)
        case 5:
            cell.textLabel?.text = self.objectList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.objectList[indexPath.row].date)
        default:
            cell.textLabel?.text = self.classList[indexPath.row].name
            cell.detailTextLabel?.text = self.getDateFormat(date: self.classList[indexPath.row].date)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.typeSelected {
        case 0:
            self.selectedObjId = self.classList[indexPath.row].id
            performSegue(withIdentifier: "detailClass", sender: self)
        case 1:
            self.selectedBookId = self.bookList[indexPath.row].id
            performSegue(withIdentifier: "detailBook", sender: self)
        case 2:
            self.selectedObjId = self.personList[indexPath.row].id
            performSegue(withIdentifier: "detailClass", sender: self)
        case 3:
            self.selectedObjId = self.eventList[indexPath.row].id
            performSegue(withIdentifier: "detailClass", sender: self)
        case 4:
            self.selectedObjId = self.placeList[indexPath.row].id
            performSegue(withIdentifier: "detailClass", sender: self)
        case 5:
            self.selectedObjId = self.objectList[indexPath.row].id
            performSegue(withIdentifier: "detailClass", sender: self)
        default:
            break
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tagBarItem: UIBarButtonItem!
    func configureToolBar () {
        let toolbarButtonItem = [searchBar, tagBarItem] as [Any]
        toolBar.setItems(toolbarButtonItem as? [UIBarButtonItem], animated: true);
    }
    @IBAction func actionTagBarItem(_ sender: UIBarButtonItem) {
        if tagPicker.isHidden == false {
            tagPicker.isHidden = true
        } else {
            tagPicker.isHidden = false
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return self.allTagList.count
        case 1:
            return self.types.count
        default:
            return self.orders.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return allTagList[row].name
        case 1:
            return self.types[row]
        default:
            return self.orders[row]
        }
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            self.tagSelected = allTagList[row]
            self.reloadTableTagChanged()
        case 1:
            self.typeSelected = row
            self.reloadTable()
        default:
            self.orderSelected = row
            self.reloadTableOrderChanged()
        }
    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailClass" {
            let destination = segue.destination as! DetailObject2ViewController
            destination.idObject = self.selectedObjId
        } else if segue.identifier == "detailBook" {
            let destination = segue.destination as! DetailBook2ViewController
            destination.idBook = self.selectedBookId
        }
    }
    
    func getDateFormat(date: String) -> String{
        let indexYear = date.index(date.startIndex, offsetBy: 4)
        let indexDay = date.index(date.startIndex, offsetBy: 8)
        let indexMonth1 = date.index(date.startIndex, offsetBy: 5)
        let indexMonth2 = date.index(date.startIndex, offsetBy: 6)
        let newDate = "\(date[indexDay...])/\(date[indexMonth1...indexMonth2])/\(date[..<indexYear])"
        return newDate
    }
}
