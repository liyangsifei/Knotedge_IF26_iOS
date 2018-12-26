//
//  EditProfileViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 26/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit
import SQLite

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var database: Connection!
    let profileView = ProfileViewController()
    
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldSurname: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPhotoBtn: UIButton!
    var profileId = 0
    var image = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        connextionBD()
        getProfile()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    
    @IBAction func changePhotoAction(_ sender: UIButton) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        present(imgPicker, animated: true, completion: nil)
        
    }

    @IBAction func doneAction(_ sender: UIButton) {
        updateProfile()
    }
    
    func updateProfile() {
        let imgData:NSData = self.image.pngData()! as NSData
        let strBase64:String = imgData.base64EncodedString(options: .lineLength64Characters)
        let sql = profileView.TABLE_PROFILE.filter(profileView.PROFILE_ID == profileId)
        let newName = fieldName.text!
        let newSurname = fieldSurname.text!
        let newEmail = fieldEmail.text!
        print("\(newName) + \(newSurname) + \(newEmail)")
        do {
            try self.database.run(sql.update(profileView.PROFILE_LAST_NAME <- newName))
            try self.database.run(sql.update(profileView.PROFILE_FIRST_NAME <- newSurname))
            try self.database.run(sql.update(profileView.PROFILE_EMAIL <- newEmail))
            try self.database.run(sql.update(profileView.PROFILE_PHOTO <- strBase64))
        } catch {
            print(error)
        }
    }
    func getProfile() {
        
        do {
            let users = try self.database.prepare(profileView.TABLE_PROFILE)
            for u in users {
                profileId = u[profileView.PROFILE_ID]
                let fName = u[profileView.PROFILE_FIRST_NAME]
                let lName = u[profileView.PROFILE_LAST_NAME]
                let photoStr = u[profileView.PROFILE_PHOTO]
                let email = u[profileView.PROFILE_EMAIL]
                let dataDecoded:NSData = NSData(base64Encoded: photoStr, options: .ignoreUnknownCharacters)!
                if let decodedImage = UIImage(data:dataDecoded as Data) {
                    self.fieldPhotoBtn.setBackgroundImage(decodedImage, for: UIControl.State.normal)
                    self.image = decodedImage
                }
                self.fieldName.text = lName
                self.fieldSurname.text = fName
                self.fieldEmail.text = email
            }
        } catch{
            print(error)
        }
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
}
