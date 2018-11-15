//
//  QCGDrawDisplay.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

class QCGDrawDisplay: NSObject ,QCGDisplay{

    func display(from vc: UIViewController, to desVc: UIViewController) {
        if let navi = vc as? UINavigationController {
            navi.drawViewController(desVc, animated: true)
        }else if let navi = vc.navigationController {
            navi.drawViewController(desVc, animated: true)
        }
    }
}

class ViewControllerNode: NSObject {
    
    static let root = ViewControllerNode()
    
    weak var parent : ViewControllerNode?
    weak var controller : UIViewController?
    var child : ViewControllerNode?
    var originX: CGFloat = 0
    var originFrame: CGRect = .zero
    
    class func insert(node: ViewControllerNode?) -> Bool {
        guard let _ = node else {
            return false
        }
        let tmp = getLast()
        node?.parent = tmp
        tmp.child = node
        return true
    }
    
    @discardableResult
    class func remove(node: ViewControllerNode?) -> Bool {
        guard let _ = node, let _ = node?.parent else {
            return false
        }
        node?.parent?.child = node?.child
        node?.child?.parent = node?.parent
        return true
    }
    
    class func getLast() -> ViewControllerNode {
        var node = root
        while node.child != nil {
            node = node.child!
        }
        return node
    }
}

public extension UIViewController {
    
    enum SlideAction {
        case open
        case close
    }
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    public func drawViewController(_ viewController: UIViewController, animated: Bool) {
        let node = ViewControllerNode()
        node.controller = viewController
        if ViewControllerNode.insert(node: node) {
            initView(viewController ,animated: animated)
        }
    }
    
    public func turnbackViewController(animated: Bool) {
        closeRightWithVelocity(0.0, animated: animated)
    }
    
    public func turnbackToViewController(_ viewController: UIViewController, animated: Bool) {
        
    }
    
    public func turnbackToRootViewController(animated: Bool) {
        
    }
    
    private func initView(_ viewController: UIViewController, animated: Bool) {
        
        guard let superV = getRootView() else {
            return
        }
        superV.backgroundColor = UIColor.clear
        getCurrentView().autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        
        let opacityView = UIView(frame: superV.bounds)
        opacityView.tag = 1020
        opacityView.backgroundColor = UIColor.black
        opacityView.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]
        opacityView.layer.opacity = 0.0
        superV.insertSubview(opacityView, at: 1)
        
        let rightContainerView = UIView(frame: superV.bounds)
        rightContainerView.frame.origin.x = rightContainerView.bounds.width
        rightContainerView.tag = 1215
        rightContainerView.backgroundColor = UIColor.clear
        rightContainerView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        superV.insertSubview(rightContainerView, at: 3)
        addRightGestures()
        setUpViewController(rightContainerView, targetViewController: viewController)
        openRight(animated: animated)
    }
    
    private func setUpViewController(_ targetView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            targetView.addSubview(viewController.view)
            superController(root: self).addChild(viewController)
            viewController.didMove(toParent: superController(root: self))
            viewController.view.frame = targetView.bounds
        }
    }
    
    
    private func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMove(toParent: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParent()
        }
    }
    
    private func openRight(animated: Bool) {
        ViewControllerNode.getLast().controller?.beginAppearanceTransition(isRightHidden(), animated: true)
        self.openRightWithVelocity(0.0 ,animated: animated)
    }
    
    private func closeRight(animated: Bool) {
        closeRightWithVelocity(0.0, animated: animated)
    }
    
    private func isRightHidden() -> Bool {
        guard let rightContainerView = getRightContainerView() else {
            return false
        }
        return rightContainerView.frame.origin.x >= self.view.bounds.width
    }
    
    private func addRightGestures() {
        let rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(UIViewController.handleRightPanGesture(_:)))
        //rightPanGesture.delegate = self
        getRightContainerView()?.addGestureRecognizer(rightPanGesture)
    }
    
    private func getRightContainerView() -> UIView? {
        return getRootView()?.viewWithTag(1215)
    }
    
    private func getOpacityView() -> UIView? {
        return getRootView()?.viewWithTag(1020)
    }
    
    private func getCurrentView() -> UIView {
        return superController(root: self).view
    }
    
    private func getRootView() -> UIView? {
        return superController(root: self).view.superview
    }
    
    private func superController(root: UIViewController) -> UIViewController {
        if let navi = root.navigationController {
            return superController(root: navi)
        }else if let tab = root.tabBarController {
            return superController(root: tab)
        }else{
            return root
        }
    }
    
    private func getOpenedRightRatio() -> CGFloat {
        
        let width: CGFloat = getRightContainerView()!.frame.size.width
        let currentPosition: CGFloat = getRightContainerView()!.frame.origin.x
        return -(currentPosition - getRootView()!.bounds.width) / width
    }
    
    private func applyRightOpacity() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let opacity: CGFloat = 0.5 * openedRightRatio
        getOpacityView()!.layer.opacity = Float(opacity)
    }
    
    private func applyRightContentViewScale() {
        let openedRightRatio: CGFloat = getOpenedRightRatio()
        let scale: CGFloat = 1.0 - ((1.0 - 0.8) * openedRightRatio)
        getCurrentView().transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    private func disableContentInteraction() {
        getCurrentView().isUserInteractionEnabled = false
    }
    
    private func enableContentInteraction() {
        getCurrentView().isUserInteractionEnabled = true
    }
    
    private func openRightWithVelocity(_ velocity: CGFloat, animated: Bool) {
        guard let rightContainerView = getRightContainerView() , let superView = getRootView() else {
            return
        }
        let finalXOrigin: CGFloat = superView.bounds.width - rightContainerView.bounds.width
        var frame = rightContainerView.frame
        frame.origin.x = finalXOrigin
        let duration: TimeInterval = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            rightContainerView.frame = frame
            self.getOpacityView()?.layer.opacity = 0.5
            self.getCurrentView().transform = CGAffineTransform(translationX: -rightContainerView.bounds.width / 2, y: 0)
        }) { (Bool) -> Void in
            self.disableContentInteraction()
        }
    }
    
    private func closeRightWithVelocity(_ velocity: CGFloat, animated: Bool) {
        guard let rightContainerView = getRightContainerView() , let superView = getRootView() else {
            return
        }
        let finalXOrigin: CGFloat = superView.bounds.width
        var frame: CGRect = rightContainerView.frame
        frame.origin.x = finalXOrigin
        
        let duration: TimeInterval = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, delay: 0.0, options: UIView.AnimationOptions(), animations: { () -> Void in
            rightContainerView.frame = frame
            self.getOpacityView()?.layer.opacity = 0.0
            self.getCurrentView().transform = CGAffineTransform(translationX: 0, y: 0)
        }) { (Bool) -> Void in
            self.enableContentInteraction()
            self.getRightContainerView()?.removeFromSuperview()
            self.getOpacityView()?.removeFromSuperview()
            let last = ViewControllerNode.getLast()
            self.removeViewController(last.controller)
            ViewControllerNode.remove(node: last)
        }
    }
    
    private func panRightResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000
        let pointOfNoReturn: CGFloat = CGFloat(floor(getRootView()!.bounds.width) - 44)
        let rightOrigin: CGFloat = getRightContainerView()!.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = rightOrigin >= pointOfNoReturn ? .close : .open
        
        if velocity.x <= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if (velocity.x >= (-1.0 * thresholdVelocity)) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    @objc private func handleRightPanGesture(_ panGesture: UIPanGestureRecognizer) {
        guard let rightContainerView = getRightContainerView() , let superView = getRootView() else {
            return
        }
        ViewControllerNode.getLast().controller?.view.endEditing(true)
        switch panGesture.state {
        case UIGestureRecognizer.State.began:
            ViewControllerNode.getLast().originFrame = rightContainerView.frame
            ViewControllerNode.getLast().originX = panGesture.location(in: superView).x
        case UIGestureRecognizer.State.changed:
            var newFrame = ViewControllerNode.getLast().originFrame
            let locX = panGesture.location(in: superView).x
            newFrame.origin.x = ViewControllerNode.getLast().originFrame.origin.x + (locX - ViewControllerNode.getLast().originX)
            if newFrame.origin.x <= 0 {
                newFrame.origin.x = 0
            }else if newFrame.origin.x >= UIScreen.main.bounds.width {
                newFrame.origin.x = UIScreen.main.bounds.width
            }
            rightContainerView.frame = newFrame
            if let _ = getOpacityView() {
                self.applyRightOpacity()
            }
            self.applyRightContentViewScale()
            
        case UIGestureRecognizer.State.ended:
            fallthrough
        case .cancelled :
            let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
            let location: CGPoint = panGesture.location(in: superView)
            
            var panInfo: PanInfo = panRightResultInfoForVelocity(velocity)
            
            if location.x >= UIScreen.main.bounds.width / 2 {
                panInfo.action = .close
            }else if velocity.x > 1000 {
                panInfo.action = .close
            }else {
                panInfo.action = .open
            }
            
            if panInfo.action == .open {
                self.openRightWithVelocity(panInfo.velocity, animated: true)
            } else {
                self.closeRightWithVelocity(panInfo.velocity, animated: true)
            }
        default:
            break
        }
    }
    
}
