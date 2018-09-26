//
//  ViewController.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.

import UIKit

class ViewController: UIViewController {
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func didPressButton() {
//        let sb = UIStoryboard.init(name: "Main", bundle: Bundle.main)
//        let vc = sb.instantiateViewController(withIdentifier: "TableViewController")
        
//        let vc = sb.instantiateViewController(withIdentifier: "MainViewController") as! DemoViewController
//        let mainView = vc.demoView
        var headerView: BottomSheetHeaderView?
        let headerNib = UINib(nibName: "CustomHeader", bundle: .main)
        if let hView = headerNib.instantiate(withOwner: self, options: nil).first as? BottomSheetHeaderView {
            headerView = hView
            let nib = UINib(nibName: "DemoView", bundle: Bundle.main)
            if let view = nib.instantiate(withOwner: nil, options: nil).first as? BottomSheetView {
                BottomSheetManager.shared.showWith(view, headerView: hView)
            }
        }
//        let headerView = BottomSheetHeaderView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        headerView.backgroundColor = UIColor.red
        
        
//        BottomSheetManager.shared.showWith(vc as! BottomSheetTableViewController, headerView: headerView)
//        BottomSheetManager.shared.showWith(vc as! BottomSheetTableViewController)
    }

    
    @IBAction func didPressOtherButton() {
        BottomSheetManager.shared.addCell()
    }
}

