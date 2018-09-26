//
//  BottomSheetHeaderView.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.

import UIKit

protocol BottomSheetHeaderViewDelegate: class {
    func didAdjustHeight(_ height: CGFloat)
    func didOverPan()
    func panDidRelease(_ startPoint: CGPoint, _ endPoint: CGPoint, _ velocity: CGPoint)
}

class BottomSheetHeaderView: UIView {

    weak var delegate: BottomSheetHeaderViewDelegate!
    
    var startingPoint: CGPoint?
    
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setupPanGestureRecognizer()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupPanGestureRecognizer()
    }
    
    
    fileprivate func setupPanGestureRecognizer() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGR)
    }


    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {

        if gestureRecognizer.state == .began {
            startingPoint = gestureRecognizer.location(in: self.superview)
        }
        
        let currentPoint = gestureRecognizer.location(in: self.superview)
        
        if startingPoint!.y - currentPoint.y < -200 {
            delegate.didOverPan()
            //toggling this back and forth quickly "cancels" the current touch without disabling the gesture recognizer.
            gestureRecognizer.isEnabled = false
            gestureRecognizer.isEnabled = true
        }
    
        guard let view = gestureRecognizer.view, view == self else { return }
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            let translation = gestureRecognizer.translation(in: self)
            delegate.didAdjustHeight(translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        }

        if gestureRecognizer.state == .ended, let startingPoint = startingPoint {
            let velocity = gestureRecognizer.velocity(in: self.superview)
            let endpoint = gestureRecognizer.location(in: self.superview)
            delegate.panDidRelease(startingPoint, endpoint, velocity)
        }
    }
    
}
