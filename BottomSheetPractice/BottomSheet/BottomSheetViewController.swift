//
//  BottomSheetViewController.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.

import UIKit


class BottomSheetViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    
    
}

protocol BottomSheetViewDelegate {
    func viewDidUpdateHeight(_ height: CGFloat)
}

class BottomSheetView: UIView {
    
    var delegate: BottomSheetViewDelegate!
    
    var contentHeight: CGFloat? {
        didSet {
            guard let contentHeight = contentHeight else { return }
            delegate.viewDidUpdateHeight(contentHeight)
        }
    }
    
    var originalFrame: CGRect {
        let currentTransform = transform
        transform = .identity
        let originalFrame = frame
        transform = currentTransform
        return originalFrame
    }
    
    var verticalOffset: CGFloat {
        return originalFrame.origin.applying(transform).y
    }
    
//    func newPointInView(_ point: CGPoint) -> CGPoint {
//        // get offset from center
//        let offset = centerOffset(point)
//        // get transformed point
//        let transformedPoint = offset.applying(transform)
//        // make relative to center
//        return pointRelativeToCenter(transformedPoint)
//    }
//
//    func pointRelativeToCenter(_ point: CGPoint) -> CGPoint {
//        return CGPoint(x: point.x + center.x, y: point.y + center.y)
//    }
//
//    func centerOffset(_ point: CGPoint) -> CGPoint {
//        return CGPoint(x: point.x - center.x, y: point.y - center.y)
//    }
}
