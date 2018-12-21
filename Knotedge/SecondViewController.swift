//
//  SecondViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 18/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class SecondViewController: UIViewController {

    var database:Connection!
    let TABLE_TAG = Table("tag")
    let TAG_ID =  Expression<Int>("tag_id")
    let TAG_NAME = Expression<String>("tag_name")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        insertTag()
        count()

        // Do any additional setup after loading the view.
    }
    
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
    
    func insertTag () {
        let insert1 = self.TABLE_TAG.insert(self.TAG_ID <- counting()+1, self.TAG_NAME <- "tag1")
        do {
            try self.database.run(insert1)
            print ("Insert1 ok")
        } catch {
            print (error)
        }
    }
    
    func counting() -> Int {
        var resultat = 0
        do {
            resultat = try self.database.scalar(TABLE_TAG.count)
        }
        catch {
            print (error)
            resultat = -1
        }
        return resultat
    }
    
    func count () {
        var resultat = 0
        do {
            resultat = try self.database.scalar(TABLE_TAG.count)
            print ("table tag = ", resultat)
        }
        catch {
            print (error)
            resultat = -1
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

}
