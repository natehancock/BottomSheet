//
//  DemoViewController.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.

import UIKit

class DemoViewController: UIViewController {
    @IBOutlet weak var demoView: DemoView!
    
    
}


class DemoView: BottomSheetView, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textField.delegate = self
    }
    @IBAction func didPressButton() {
        
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}
