//
//  EditProfileViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 18/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    @IBOutlet weak var buttonImageProfile: UIButton!
    @IBOutlet weak var fieldLastName: UITextField!
    @IBOutlet weak var fieldFirstName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func actionButtonImage(_ sender: Any) {
    }
    
    @IBAction func ActionDone(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func ActionCancel(_ sender: UIBarButtonItem) {
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
