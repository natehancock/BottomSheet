//
//  BottomSheetTableViewController.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.

import UIKit

protocol BottomSheetViewControllerDelegate {
    func adjustHeight(_ height: CGFloat)
}

class BottomSheetTableViewController: UITableViewController {
    
    var labels = ["This", "IS", "A", "DEMO"]
    
    var delegate: BottomSheetViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentSize" else {
            return
        }
        delegate.adjustHeight(tableView.contentSize.height)
    }
    

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! LabelCell
        cell.label.text = labels[indexPath.row]
        return cell
    }
}
