//
//  BottomSheetManager.swift
//  BottomSheetPractice
//
//  Created by Nathan Hancock on 9/19/18.
//

import UIKit

enum BottomSheetState {
    case standard
    case isDismissing
}

class BottomSheetManager {
    static let shared = BottomSheetManager()
    
    var tableViewController: BottomSheetTableViewController?
    var mainView: BottomSheetView?
    var headerView: BottomSheetHeaderView?
    var window: PassthroughWindow?
    
    var scrim: BottomSheetScrimView?
    
    
    var keyboardHeight: CGFloat = 0
    var threshold: CGFloat? = 0.15
    
    /// Points/second
    final let viewVelocity: CGFloat = 1100
    
    final let screenHeight = UIScreen.main.bounds.height
    
    func addCell() {
        guard let tableViewController = tableViewController else { return }
        let random = Int.random(in: 0..<10)
        tableViewController.labels.append("ANOTHER ONE: \(String(describing: random))")
        tableViewController.tableView.reloadData()
    }
    
    func showWith(_ tableVC: BottomSheetTableViewController) {
        setTableViewController(tableVC)
        addWindow()
    }
    
//    /// Currently broken
//    func showWith(_ tableVC: BottomSheetTableViewController, headerView: BottomSheetHeaderView) {
//        setTableViewController(tableVC)
//        setHeaderView(headerView)
//        addWindow()
//    }
    
    func showWith(_ view: BottomSheetView, headerView: BottomSheetHeaderView) {
        setView(view)
        setHeaderView(headerView)
        addWindow()
    }
    

    

}

extension BottomSheetManager {
    fileprivate func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc fileprivate func keyboardWillShow(responder: Notification) {
        guard let window = window else { return }
        
        if let keyboardRect = responder.userInfo?["UIKeyboardBoundsUserInfoKey"] as? CGRect {
            keyboardHeight = keyboardRect.height
            let t = window.layer.affineTransform().translatedBy(x: 0, y: -keyboardHeight)
            window.layer.setAffineTransform(t)
        }
        
    }
    
    @objc fileprivate func keyboardWillHide(responder: UIResponder) {
        keyboardHeight = 0
        animateToDefault()
    }
}

extension BottomSheetManager {

    
    fileprivate func animateOffScreen() {
        guard let window = window else { return }
        
        let distance = (abs(screenHeight) - abs(window.frame.origin.y))
        let time = abs(distance / viewVelocity)
        
        UIView.animate(withDuration: TimeInterval(time), animations: {
            window.transform = CGAffineTransform.init(translationX: 0, y: self.screenHeight)
            
            if let scrim = self.scrim {
                scrim.alpha = 0.0
            }
            
        }) { (finished) in
            self.removeWindow()
        }
    }
    
    fileprivate func animateToDefault() {
        guard let window = window, let contentHeight = mainView?.contentHeight else { return }
        let defaultHeight = screenHeight - contentHeight - 50 - keyboardHeight
        print(defaultHeight)
        if let time = calculateTimeForAnimation(withHeight: defaultHeight) {
            UIView.animate(withDuration: TimeInterval(time)) {
                window.transform = CGAffineTransform.init(translationX: 0, y: defaultHeight)
                if let scrim = self.scrim {
                    scrim.alpha = 1.0
                }
            }
        }
    }
    
    fileprivate func springToDefault() {
        guard let window = window, let contentHeight = mainView?.contentHeight else { return }
        let defaultHeight = screenHeight - contentHeight - 50 - keyboardHeight
        if let time = calculateTimeForAnimation(withHeight: defaultHeight) {
            UIView.animate(withDuration: TimeInterval(time), delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                window.transform = CGAffineTransform.init(translationX: 0, y: defaultHeight)
            }) { (finished) in
                
            }
        }
    }
    
    fileprivate func calculateTimeForAnimation(withHeight: CGFloat) -> CGFloat? {
        guard let window = window else { return nil }
    
        let distance = abs(abs(withHeight) - abs(window.frame.origin.y))
        let time = abs(distance / viewVelocity)
        return time <= 0.3 ? time : 0.3
    }
    
    fileprivate func exceedsThreshold(for difference: CGFloat) -> Bool {
        return abs(Int(difference)) > Int(self.threshold! * UIScreen.main.bounds.height)
    }
}

extension BottomSheetManager: BottomSheetViewControllerDelegate {
    internal func adjustHeight(_ height: CGFloat) {
        
    }
}

extension BottomSheetManager: BottomSheetHeaderViewDelegate {
    
    internal func didAdjustHeight(_ height: CGFloat) {
        guard let window = window else { return }
        
        let t = window.layer.affineTransform().translatedBy(x: 0, y: height)
        window.layer.setAffineTransform(t)
    }
    
    internal func panDidRelease(_ startPoint: CGPoint, _ endPoint: CGPoint, _ velocity: CGPoint) {
        let difference = startPoint.y - endPoint.y
        if difference > 0 && exceedsThreshold(for: difference) {
            animateOffScreen()
            return
        }
        springToDefault()
    }
    
    func didOverPan() {
        springToDefault()
    }
}

extension BottomSheetManager: BottomSheetViewDelegate {
    func viewDidUpdateHeight(_ height: CGFloat) {
        animateToDefault()
    }
}

extension BottomSheetManager: BottomSheetScrimViewDelegate {
    func didTapView(sender: BottomSheetScrimView) {
        animateOffScreen()
    }
}




extension BottomSheetManager {
    
    private func setView(_ view: BottomSheetView) {
        self.mainView = view
        self.mainView?.delegate = self
    }
    
    private func setTableViewController(_ tableViewController: BottomSheetTableViewController) {
        self.tableViewController = tableViewController
        self.tableViewController?.delegate = self
    }
    
    private func setHeaderView(_ headerView: BottomSheetHeaderView) {
        self.headerView = headerView
        self.headerView?.delegate = self
    }
    
    private func setScrim(_ scrim: BottomSheetScrimView) {
        self.scrim = scrim
        self.scrim?.delegate = self
    }
    
    private func addWindow() {
        if window != nil { return }
        addNotifications()
        
        
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        //        let windowRect = CGRect(x: 0, y: -keyWindow.frame.height, width: keyWindow.frame.width, height: keyWindow.frame.height)
        window = PassthroughWindow(frame: keyWindow.frame)
        setScrim(BottomSheetScrimView())
        guard let window = window, let scrim = scrim else { return }
        
        keyWindow.addSubview(scrim)
        scrim.translatesAutoresizingMaskIntoConstraints = false
        scrim.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
        scrim.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
        scrim.leftAnchor.constraint(equalTo: keyWindow.leftAnchor).isActive = true
        scrim.rightAnchor.constraint(equalTo: keyWindow.rightAnchor).isActive = true
        scrim.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        scrim.alpha = 0.0
        
        keyWindow.addSubview(window)
        
        //set constraints for Window
        window.translatesAutoresizingMaskIntoConstraints = false
        window.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor).isActive = true
        window.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor).isActive = true
        window.topAnchor.constraint(equalTo: keyWindow.topAnchor).isActive = true
        window.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor).isActive = true
        window.isHidden = true
        
        window.transform = .init(translationX: 0, y: keyWindow.frame.height)
        
        
        
        
        
        guard let headerView = headerView else {
            return
        }
        
        window.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: window.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        //add tableVC to window
        if let tableViewController = tableViewController {
            window.addSubview(tableViewController.view)
            tableViewController.view.translatesAutoresizingMaskIntoConstraints = false
            tableViewController.view.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            tableViewController.view.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            tableViewController.view.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
            tableViewController.view.bottomAnchor.constraint(equalTo: window.bottomAnchor).isActive = true
            
            tableViewController.tableView.reloadData()
        }
        
        if let mainView = mainView {
            window.addSubview(mainView)
            
            mainView.translatesAutoresizingMaskIntoConstraints = false
            mainView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            mainView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            mainView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
            
            let preferredSize = mainView.systemLayoutSizeFitting(.zero, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
            mainView.contentHeight = preferredSize.height
            
            let hideView = UIView()
            hideView.backgroundColor = mainView.backgroundColor
            window.addSubview(hideView)
            hideView.translatesAutoresizingMaskIntoConstraints = false
            hideView.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            hideView.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true
            hideView.topAnchor.constraint(equalTo: mainView.bottomAnchor).isActive = true
            hideView.bottomAnchor.constraint(equalTo: window.bottomAnchor, constant: 50).isActive = true
        }
        
        window.makeKeyAndVisible()
    }
    
    fileprivate func removeWindow() {
        self.window?.resignKey()
        self.window?.removeFromSuperview()
        self.window?.isHidden = true
        self.window = nil
        
        self.scrim?.removeFromSuperview()
        self.scrim = nil
        
        keyboardHeight = 0
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
