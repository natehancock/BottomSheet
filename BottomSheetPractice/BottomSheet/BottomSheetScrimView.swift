//
//  BottomSheetScrimView.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/21/18.

import UIKit

protocol BottomSheetScrimViewDelegate {
    func didTapView(sender: BottomSheetScrimView)
}

class BottomSheetScrimView: UIView {
    
    var delegate: BottomSheetScrimViewDelegate!
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGR)
    }
    
    @objc func didTapView() {
        delegate.didTapView(sender: self)
    }
    
    
}
