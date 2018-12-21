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
    
    @IBAction func DateTouchUpAction(_ sender: UITextField) {
        let datePicker = UIDatePicker(frame: CGRect(x:0, y:0, width:320, height:216))
        
        datePicker.locale = Locale(identifier: "fr_EN")
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        self.view.addSubview(datePicker)
    }
    
    @IBAction func beginChange(_ sender: Any) {
    }
    @objc func dateChanged(datePicker : UIDatePicker){
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM/yyyy"
        print(formatter.string(from: datePicker.date))
    }
    
    
    @IBOutlet weak var addBarItem: UIBarButtonItem!
    func configureToolBar () {
        let toolbarButtonItem = [addBarItem]
        toolBar.setItems(toolbarButtonItem as! [UIBarButtonItem], animated: true);
    }
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        print("add action")
    }
}
