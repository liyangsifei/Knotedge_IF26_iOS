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
    @IBOutlet weak var fieldDescription: UITextField!
    @IBOutlet weak var fieldDate: UITextField!
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureToolBar()
        createDatePicker()
    }
    @IBAction func touchDown(_ sender: UITextField) {
        
    }
    
    func createDatePicker() {
        datePicker.locale = NSLocale(localeIdentifier: "fr_FR") as Locale
        datePicker.timeZone = NSTimeZone.system
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.addTarget(self, action: #selector(getDate), for: UIControl.Event.valueChanged)
        datePicker.layer.backgroundColor = UIColor.white.cgColor
        datePicker.layer.masksToBounds = true
        fieldDate.inputView = datePicker
    }
    
    @objc func getDate(datePicker: UIDatePicker) {
        let formatter = DateFormatter()
        let date = datePicker.date
        formatter.dateFormat = "dd/MM/yyyy"
        let dateStr = formatter.string(from: date)
        self.fieldDate.text = dateStr
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
