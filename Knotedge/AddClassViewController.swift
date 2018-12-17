//
//  AddClassViewController.swift
//  Knotedge
//
//  Created by Sifei LI on 17/12/2018.
//  Copyright © 2018 if26. All rights reserved.
//

import UIKit

class AddClassViewController: UIViewController {

    
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var fieldName: UITextField!
    
    @IBOutlet weak var fieldDate: UITextField!
    
    @IBOutlet weak var fieldDescription: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureToolBar()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    func configureToolBar () {
        let toolbarButtonItem = [addBarItem]
        toolBar.setItems(toolbarButtonItem as! [UIBarButtonItem], animated: true);
    }
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        print("add action")
    }
}
