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
    
    //Photo Button to open the library
    @IBAction func changePhotoAction(_ sender: UIButton) {
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        present(imgPicker, animated: true, completion: nil)
    }

    //Button Done
    @IBAction func doneAction(_ sender: UIButton) {
        updateProfile()
    }
    
    //Edit profile to BD
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
    //Load profile from BD
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
    
    //Take image from library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = pickedImage
            fieldPhotoBtn.setBackgroundImage(self.image, for: UIControl.State.normal)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Listeners of the keyboard Event
    @objc func keyboardWillShow(_ notification: Notification) {
        view.frame.origin.y = -getKeyboardHeight(notification)
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
    //Connexion to DataBase
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
