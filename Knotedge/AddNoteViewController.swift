//
//  AddNoteViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {

    @IBOutlet weak var addBarItem: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureToolBar()
    }
    func configureToolBar () {
        let toolbarButtonItem = [addBarItem]
        toolBar.setItems(toolbarButtonItem as! [UIBarButtonItem], animated: true);
    }
    
    @IBAction func AddAction(_ sender: UIBarButtonItem) {
        print("add note")
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
