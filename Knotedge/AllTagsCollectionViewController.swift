//
//  AllTagsCollectionViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 27/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

private let reuseIdentifier = "tagCell"

class AllTagsCollectionViewController: UICollectionViewController {

    var database:Connection!
    let profileView = ProfileViewController()
    
    var tagList: [Tag] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        loadAllTags()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.tagList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let lab = UILabel()
        lab.textAlignment = .center
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.text = self.tagList[indexPath.row].name
        cell.contentView.addSubview(lab)
        return cell
    }
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
     */
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
            print ("tag inserted")
        } catch {
            print (error)
        }
    }
    
    @IBAction func addTagAction(_ sender: UIBarButtonItem) {
        let controller = UIAlertController(title: "New Tag", message: "", preferredStyle: UIAlertController.Style.alert)
        var inputText: UITextField = UITextField();
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            action in controller.dismiss(animated: true, completion: nil)
            self.addTag(name: inputText.text!)
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
