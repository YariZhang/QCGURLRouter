//
//  SlideMenuController.swift
//
//  Created by Yuji Hato on 12/3/14.
//

import Foundation
import UIKit


class SlideMenuOption {
    
    let leftViewWidth: CGFloat = UIScreen.main.bounds.width
    let leftBezelWidth: CGFloat = 100
    let contentViewScale: CGFloat = 1
    let contentViewOpacity: CGFloat = 0.5
    let shadowOpacity: CGFloat = 0.0
    let shadowRadius: CGFloat = 0.0
    let shadowOffset: CGSize = CGSize(width: 0,height: 0)
    let panFromBezel: Bool = true
    let animationDuration: CGFloat = 0.3
    let rightViewWidth: CGFloat = UIScreen.main.bounds.width
    let rightBezelWidth: CGFloat = 100
    let rightPanFromBezel: Bool = true
    let hideStatusBar: Bool = false
    let pointOfNoReturnWidth: CGFloat = 44.0
    
    init() {
        
    }
}


class SlideMenuController: UIViewController, UIGestureRecognizerDelegate {
    
    let SlideMenuPageMain : Int   = 0
    let SlideMenuPageLeft : Int   = 1
    let SlideMenuPageRight : Int  = 2
    
    enum SlideAction {
        case open
        case close
    }
    
    enum TrackAction {
        case tapOpen
        case tapClose
        case flickOpen
        case flickClose
    }
    
    
    struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    var isTargetVc : Bool = true
    var opacityView = UIView()
    var mainContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView =  UIView()
    var mainViewController: UIViewController?
    var leftViewController: UIViewController?
    var leftPanGesture: UIPanGestureRecognizer?
    var leftTapGetsture: UITapGestureRecognizer?
    var rightViewController: UIViewController?
    var rightPanGesture: UIPanGestureRecognizer?
    var rightTapGesture: UITapGestureRecognizer?
    var options = SlideMenuOption()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        self.leftViewController = leftMenuViewController
        self.initView()
    }
    
    convenience init(mainViewController: UIViewController?, rightMenuViewController: UIViewController?) {
        self.init()
        self.mainViewController = mainViewController
        self.rightViewController = rightMenuViewController
        self.initView()
    }
    
    convenience init(mainViewController: UIViewController, leftMenuViewController: UIViewController, rightMenuViewController: UIViewController) {
        self.init()
        self.mainViewController = mainViewController
        self.leftViewController = leftMenuViewController
        self.rightViewController = rightMenuViewController
        self.initView()
    }
    
    deinit { }
    
    func initView() {
        mainContainerView = UIView(frame: self.view.bounds)
        mainContainerView.backgroundColor = UIColor.clear
        mainContainerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.view.insertSubview(mainContainerView, at: 0)

        var opacityframe: CGRect = self.view.bounds
        let opacityOffset: CGFloat = 0
        opacityframe.origin.y = opacityframe.origin.y + opacityOffset
        opacityframe.size.height = opacityframe.size.height - opacityOffset
        opacityView = UIView(frame: opacityframe)
        opacityView.backgroundColor = UIColor.black
        opacityView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        opacityView.layer.opacity = 0.0
        self.view.insertSubview(opacityView, at: 1)
        
        var leftFrame: CGRect = self.view.bounds
        leftFrame.size.width = self.options.leftViewWidth
        leftFrame.origin.x = self.leftMinOrigin();
        let leftOffset: CGFloat = 0
        leftFrame.origin.y = leftFrame.origin.y + leftOffset
        leftFrame.size.height = leftFrame.size.height - leftOffset
        leftContainerView = UIView(frame: leftFrame)
        leftContainerView.backgroundColor = UIColor.clear
        leftContainerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.view.insertSubview(leftContainerView, at: 2)
        
        var rightFrame: CGRect = self.view.bounds
        rightFrame.size.width = self.options.rightViewWidth
        rightFrame.origin.x = self.rightMinOrigin()
        let rightOffset: CGFloat = 0
        rightFrame.origin.y = rightFrame.origin.y + rightOffset;
        rightFrame.size.height = rightFrame.size.height - rightOffset
        rightContainerView = UIView(frame: rightFrame)
        rightContainerView.backgroundColor = UIColor.clear
        rightContainerView.autoresizingMask = UIViewAutoresizing.flexibleHeight
        self.view.insertSubview(rightContainerView, at: 3)
        
        
        self.addLeftGestures()
        self.addRightGestures()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) in
            self.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.leftContainerView.isHidden = true
            self.rightContainerView.isHidden = true
        }, completion: {(context) in
            self.closeLeftNonAnimation()
            self.closeRightNonAnimation()
            self.leftContainerView.isHidden = false
            self.rightContainerView.isHidden = false
            
            self.removeLeftGestures()
            self.removeRightGestures()
            self.addLeftGestures()
            self.addRightGestures()
        })
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge()
    }
    
    override func viewWillLayoutSubviews() {
        // topLayoutGuideの値が確定するこのタイミングで各種ViewControllerをセットする
        self.setUpViewController(self.mainContainerView, targetViewController: self.mainViewController)
        self.setUpViewController(self.leftContainerView, targetViewController: self.leftViewController)
        self.setUpViewController(self.rightContainerView, targetViewController: self.rightViewController)
    }
    
    override func openLeft() {
        //self.setOpenWindowLevel()
        
        //leftViewControllerのviewWillAppearを呼ぶため
        self.leftViewController?.beginAppearanceTransition(self.isLeftHidden(), animated: true)
        self.openLeftWithVelocity(0.0)
        
        self.track(.tapOpen)
    }
    
    override func openRight() {
        //self.setOpenWindowLevel()
        
        //menuViewControllerのviewWillAppearを呼ぶため
        self.rightViewController?.beginAppearanceTransition(self.isRightHidden(), animated: true)
        self.openRightWithVelocity(0.0)
    }
    
    override func closeLeft() {
        self.closeLeftWithVelocity(0.0)
        self.setCloseWindowLebel()
    }
    
    override func closeRight() {
        self.closeRightWithVelocity(0.0)
        self.setCloseWindowLebel()
    }
    
    
    func addLeftGestures() {
    
        if (self.leftViewController != nil) {
            if self.leftPanGesture == nil {
                self.leftPanGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideMenuController.handleLeftPanGesture(_:)))
                self.leftPanGesture!.delegate = self
                self.view.addGestureRecognizer(self.leftPanGesture!)
            }
            
            if self.leftTapGetsture == nil {
                self.leftTapGetsture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.toggleLeft))
                self.leftTapGetsture!.delegate = self
                self.view.addGestureRecognizer(self.leftTapGetsture!)
            }
        }
    }
    
    func addRightGestures() {
        
        if (self.rightViewController != nil) {
            if self.rightPanGesture == nil {
                self.rightPanGesture = UIPanGestureRecognizer(target: self, action: #selector(SlideMenuController.handleRightPanGesture(_:)))
                self.rightPanGesture!.delegate = self
                self.rightContainerView.addGestureRecognizer(self.rightPanGesture!)
            }
            
            if self.rightTapGesture == nil {
                self.rightTapGesture = UITapGestureRecognizer(target: self, action: #selector(UIViewController.toggleRight))
                self.rightTapGesture!.delegate = self
                self.view.addGestureRecognizer(self.rightTapGesture!)
            }
        }
    }
    
    func removeLeftGestures() {
        
        if self.leftPanGesture != nil {
            self.view.removeGestureRecognizer(self.leftPanGesture!)
            self.leftPanGesture = nil
        }
        
        if self.leftTapGetsture != nil {
            self.view.removeGestureRecognizer(self.leftTapGetsture!)
            self.leftTapGetsture = nil
        }
    }
    
    func removeRightGestures() {
        
        if self.rightPanGesture != nil {
            self.view.removeGestureRecognizer(self.rightPanGesture!)
            self.rightPanGesture = nil
        }
        
        if self.rightTapGesture != nil {
            self.view.removeGestureRecognizer(self.rightTapGesture!)
            self.rightTapGesture = nil
        }
    }
    
    func isTagetViewController() -> Bool {
        // Function to determine the target ViewController
        // Please to override it if necessary
        return isTargetVc
    }
    
    func track(_ trackAction: TrackAction) {
        // function is for tracking
        // Please to override it if necessary
    }
    
    struct LeftPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    func handleLeftPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !self.isTagetViewController() {
            return
        }
        
        if self.isRightOpen() {
            return
        }
        
        switch panGesture.state {
            case UIGestureRecognizerState.began:
                
                LeftPanState.frameAtStartOfPan = self.leftContainerView.frame
                LeftPanState.startPointOfPan = panGesture.location(in: self.view)
                LeftPanState.wasOpenAtStartOfPan = self.isLeftOpen()
                LeftPanState.wasHiddenAtStartOfPan = self.isLeftHidden()
                
                self.leftViewController?.beginAppearanceTransition(LeftPanState.wasHiddenAtStartOfPan, animated: true)
                self.addShadowToView(self.leftContainerView)
                //self.setOpenWindowLevel()
            case UIGestureRecognizerState.changed:
                
                let translation: CGPoint = panGesture.translation(in: panGesture.view!)
                self.leftContainerView.frame = self.applyLeftTranslation(translation, toFrame: LeftPanState.frameAtStartOfPan)
                self.applyLeftOpacity()
                self.applyLeftContentViewScale()
            case UIGestureRecognizerState.ended:
                fallthrough
        case .cancelled :
            
                self.leftViewController?.beginAppearanceTransition(!LeftPanState.wasHiddenAtStartOfPan, animated: true)
                let velocity:CGPoint = panGesture.velocity(in: panGesture.view)
                let location: CGPoint = panGesture.location(in: panGesture.view)
                
                var panInfo: PanInfo = self.panLeftResultInfoForVelocity(velocity)
                if location.x >= UIScreen.main.bounds.width / 2 {
                    panInfo.action = .open
                }else if velocity.x > 1000 {
                    panInfo.action = .open
                }else {
                    panInfo.action = .close
                }
                
                if panInfo.action == .open {
                    self.openLeftWithVelocity(panInfo.velocity)
                    self.track(.flickOpen)
                    
                } else {
                    self.closeLeftWithVelocity(panInfo.velocity)
                    self.setCloseWindowLebel()
                    
                    self.track(.flickClose)

                }
        default:
            break
        }
        
    }
    
    struct rightPanState {
        static var frameAtStartOfPan: CGRect = CGRect.zero
        static var startPointOfPan: CGPoint = CGPoint.zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    var originX : CGFloat = 0
    var originFrame : CGRect = CGRect.zero
    func handleRightPanGesture(_ panGesture: UIPanGestureRecognizer) {
        
        if !self.isTagetViewController() {
            return
        }
        
        if self.isLeftOpen() {
            return
        }
        self.rightViewController?.view.endEditing(true)
        switch panGesture.state {
        case UIGestureRecognizerState.began:
            
            //rightPanState.frameAtStartOfPan = self.rightContainerView.frame
            //rightPanState.startPointOfPan = panGesture.locationInView(self.view)
            originFrame = self.rightContainerView.frame
            originX = panGesture.location(in: self.view).x
            //rightPanState.wasOpenAtStartOfPan =  self.isRightOpen()
            //rightPanState.wasHiddenAtStartOfPan = self.isRightHidden()
            
            //self.rightViewController?.beginAppearanceTransition(rightPanState.wasHiddenAtStartOfPan, animated: true)
            self.addShadowToView(self.view)
            //self.setOpenWindowLevel()
        case UIGestureRecognizerState.changed:
            var newFrame = originFrame
            let locX = panGesture.location(in: self.view).x
            newFrame.origin.x = originFrame.origin.x + (locX - originX)
            if newFrame.origin.x <= 0 {
                newFrame.origin.x = 0
            }else if newFrame.origin.x >= UIScreen.main.bounds.width {
                newFrame.origin.x = UIScreen.main.bounds.width
            }
            //let translation: CGPoint = panGesture.translationInView(panGesture.view!)
            self.rightContainerView.frame = newFrame//self.applyRightTranslation(translation, toFrame: rightPanState.frameAtStartOfPan)
            self.applyRightOpacity()
            self.applyRightContentViewScale()
            
        case UIGestureRecognizerState.ended:
            fallthrough
        case .cancelled :
            //self.rightViewController?.beginAppearanceTransition(!rightPanState.wasHiddenAtStartOfPan, animated: true)
            let velocity: CGPoint = panGesture.velocity(in: panGesture.view)
            let location: CGPoint = panGesture.location(in: self.view)
            
            var panInfo: PanInfo = self.panRightResultInfoForVelocity(velocity)
            
            if location.x >= UIScreen.main.bounds.width / 2 {
                panInfo.action = .close
            }else if velocity.x > 1000 {
                panInfo.action = .close
            }else {
                panInfo.action = .open
            }
            
            if panInfo.action == .open {
                self.openRightWithVelocity(panInfo.velocity)
            } else {
                self.closeRightWithVelocity(panInfo.velocity)
                self.setCloseWindowLebel()
            }
        default:
            break
        }
    }
    
    func openLeftWithVelocity(_ velocity: CGFloat) {
        self.mainViewController?.willDisappear(SlideMenuPageLeft)
        let xOrigin: CGFloat = self.leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = 0.0
        
        var frame = self.leftContainerView.frame;
        frame.origin.x = finalXOrigin;
        
        var duration: TimeInterval = Double(self.options.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        self.addShadowToView(self.leftContainerView)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.leftContainerView.frame = frame
            self.leftViewController?.willAppear(self.SlideMenuPageMain)
            self.opacityView.layer.opacity = Float(self.options.contentViewOpacity)
            self.mainContainerView.transform = CGAffineTransform(scaleX: self.options.contentViewScale, y: self.options.contentViewScale)
        }) { (Bool) -> Void in
            self.disableContentInteraction()
            self.leftViewController?.didAppear(self.SlideMenuPageMain)
        }
    }
    
    func openRightWithVelocity(_ velocity: CGFloat) {
        self.mainViewController?.willDisappear(SlideMenuPageRight)
        //let xOrigin: CGFloat = self.rightContainerView.frame.origin.x
    
        //	CGFloat finalXOrigin = self.options.rightViewOverlapWidth;
        let finalXOrigin: CGFloat = self.view.bounds.width - self.rightContainerView.frame.size.width
        
        var frame = self.rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        let duration: TimeInterval = Double(self.options.animationDuration)
        /*if velocity != 0.0 {
            duration = Double(fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }*/
    
        self.addShadowToView(self.rightContainerView)
    
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.rightContainerView.frame = frame
            self.rightViewController?.willAppear(self.SlideMenuPageMain)
            self.opacityView.layer.opacity = Float(self.options.contentViewOpacity)
            self.mainContainerView.transform = CGAffineTransform(scaleX: self.options.contentViewScale, y: self.options.contentViewScale)
            }) { (Bool) -> Void in
                self.disableContentInteraction()
                self.rightViewController?.didAppear(self.SlideMenuPageMain)
        }
    }
    
    func closeLeftWithVelocity(_ velocity: CGFloat) {
        self.leftViewController?.willDisappear(self.SlideMenuPageMain)
        let xOrigin: CGFloat = self.leftContainerView.frame.origin.x
        let finalXOrigin: CGFloat = self.leftMinOrigin()
        
        var frame: CGRect = self.leftContainerView.frame;
        frame.origin.x = finalXOrigin
    
        var duration: TimeInterval = Double(self.options.animationDuration)
        if velocity != 0.0 {
            duration = Double(fabs(xOrigin - finalXOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.leftContainerView.frame = frame
            self.mainViewController?.willAppear(self.SlideMenuPageLeft)
            self.opacityView.layer.opacity = 0.0
            self.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (Bool) -> Void in
                self.removeShadow(self.leftContainerView)
                self.enableContentInteraction()
                self.mainViewController?.didAppear(self.SlideMenuPageLeft)
        }
    }
    
    
    func closeRightWithVelocity(_ velocity: CGFloat) {
        self.rightViewController?.willDisappear(self.SlideMenuPageMain)
        //let xOrigin: CGFloat = self.rightContainerView.frame.origin.x
        let finalXOrigin: CGFloat = self.view.bounds.width
    
        var frame: CGRect = self.rightContainerView.frame
        frame.origin.x = finalXOrigin
    
        let duration: TimeInterval = Double(self.options.animationDuration)
        /*if velocity != 0.0 {
            duration = Double(fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }*/
        
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.rightContainerView.frame = frame
            self.mainViewController?.willAppear(self.SlideMenuPageRight)
            self.opacityView.layer.opacity = 0.0
            self.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (Bool) -> Void in
                self.removeShadow(self.rightContainerView)
                self.enableContentInteraction()
                self.changeRightViewController(UIViewController(), closeRight: false)
                self.mainViewController?.didAppear(self.SlideMenuPageRight)
        }
    }
    
    
    override func toggleLeft() {
        if self.isLeftOpen() {
            self.closeLeft()
            self.setCloseWindowLebel()
            
            self.track(.tapClose)
        } else {
            self.openLeft()
        }
    }
    
    func isLeftOpen() -> Bool {
        return self.leftContainerView.frame.origin.x == 0.0
    }
    
    func isLeftHidden() -> Bool {
        return self.leftContainerView.frame.origin.x <= self.leftMinOrigin()
    }
    
    override func toggleRight() {
        if self.isRightOpen() {
            self.closeRight()
            self.setCloseWindowLebel()
        } else {
            self.openRight()
        }
    }
    
    func isRightOpen() -> Bool {
        return self.rightContainerView.frame.origin.x == self.view.bounds.width - self.rightContainerView.frame.size.width
    }
    
    func isRightHidden() -> Bool {
        return self.rightContainerView.frame.origin.x >= self.view.bounds.width
    }
    
    func changeMainViewController(_ mainViewController: UIViewController,  close: Bool) {
        
        self.removeViewController(self.mainViewController)
        self.mainViewController = mainViewController
        self.setUpViewController(self.mainContainerView, targetViewController: self.mainViewController)
        if (close) {
            self.closeLeft()
            self.closeRight()
        }
    }
    
    func changeLeftViewController(_ leftViewController: UIViewController, closeLeft:Bool) {
        
        self.removeViewController(self.leftViewController)
        self.leftViewController = leftViewController
        self.setUpViewController(self.leftContainerView, targetViewController: self.leftViewController)
        if (closeLeft) {
            self.closeLeft()
        }
    }
    
    func changeRightViewController(_ rightViewController: UIViewController, closeRight:Bool) {
        self.removeViewController(self.rightViewController)
        self.rightViewController = rightViewController;
        self.setUpViewController(self.rightContainerView, targetViewController: self.rightViewController)
        if (closeRight) {
            self.closeRight()
        }
    }
    
    fileprivate func leftMinOrigin() -> CGFloat {
        return  -self.options.leftViewWidth
    }
    
    fileprivate func rightMinOrigin() -> CGFloat {
        return self.view.bounds.width
    }
    
    
    fileprivate func panLeftResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000
        let pointOfNoReturn: CGFloat = CGFloat(floor(self.leftMinOrigin())) + self.options.pointOfNoReturnWidth
        let leftOrigin: CGFloat = self.leftContainerView.frame.origin.x
        
        var panInfo: PanInfo = PanInfo(action: .close, shouldBounce: false, velocity: 0.0)
        
        panInfo.action = leftOrigin <= pointOfNoReturn ? .close : .open;
        
        if velocity.x >= thresholdVelocity {
            panInfo.action = .open
            panInfo.velocity = velocity.x
        } else if velocity.x <= (-1.0 * thresholdVelocity) {
            panInfo.action = .close
            panInfo.velocity = velocity.x
        }
        
        return panInfo
    }
    
    fileprivate func panRightResultInfoForVelocity(_ velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = 1000
        let pointOfNoReturn: CGFloat = CGFloat(floor(self.view.bounds.width) - self.options.pointOfNoReturnWidth)
        let rightOrigin: CGFloat = self.rightContainerView.frame.origin.x
        
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
    
    fileprivate func applyLeftTranslation(_ translation: CGPoint, toFrame:CGRect) -> CGRect {
        
        var newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = self.leftMinOrigin()
        let maxOrigin: CGFloat = 0.0
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func applyRightTranslation(_ translation: CGPoint, toFrame: CGRect) -> CGRect {
        
        var  newOrigin: CGFloat = toFrame.origin.x
        newOrigin += translation.x
        
        let minOrigin: CGFloat = self.rightMinOrigin()
        //        var maxOrigin: CGFloat = self.options.rightViewOverlapWidth
        let maxOrigin: CGFloat = self.rightMinOrigin() - self.rightContainerView.frame.size.width
        var newFrame: CGRect = toFrame
        
        if newOrigin > minOrigin {
            newOrigin = minOrigin
        } else if newOrigin < maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.x = newOrigin
        return newFrame
    }
    
    fileprivate func getOpenedLeftRatio() -> CGFloat {
        
        let width: CGFloat = self.leftContainerView.frame.size.width
        let currentPosition: CGFloat = self.leftContainerView.frame.origin.x - self.leftMinOrigin()
        return currentPosition / width
    }
    
    fileprivate func getOpenedRightRatio() -> CGFloat {
        
        let width: CGFloat = self.rightContainerView.frame.size.width
        let currentPosition: CGFloat = self.rightContainerView.frame.origin.x
        return -(currentPosition - self.view.bounds.width) / width
    }
    
    fileprivate func applyLeftOpacity() {
        
        let openedLeftRatio: CGFloat = self.getOpenedLeftRatio()
        let opacity: CGFloat = self.options.contentViewOpacity * openedLeftRatio
        self.opacityView.layer.opacity = Float(opacity)
    }
    
    
    fileprivate func applyRightOpacity() {
        let openedRightRatio: CGFloat = self.getOpenedRightRatio()
        let opacity: CGFloat = self.options.contentViewOpacity * openedRightRatio
        self.opacityView.layer.opacity = Float(opacity)
    }
    
    fileprivate func applyLeftContentViewScale() {
        let openedLeftRatio: CGFloat = self.getOpenedLeftRatio()
        let scale: CGFloat = 1.0 - ((1.0 - self.options.contentViewScale) * openedLeftRatio);
        self.mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    fileprivate func applyRightContentViewScale() {
        let openedRightRatio: CGFloat = self.getOpenedRightRatio()
        let scale: CGFloat = 1.0 - ((1.0 - self.options.contentViewScale) * openedRightRatio)
        self.mainContainerView.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    fileprivate func addShadowToView(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = false
        targetContainerView.layer.shadowOffset = self.options.shadowOffset
        targetContainerView.layer.shadowOpacity = Float(self.options.shadowOpacity)
        targetContainerView.layer.shadowRadius = self.options.shadowRadius
        targetContainerView.layer.shadowPath = UIBezierPath(rect: targetContainerView.bounds).cgPath
    }
    
    fileprivate func removeShadow(_ targetContainerView: UIView) {
        targetContainerView.layer.masksToBounds = true
        self.mainContainerView.layer.opacity = 1.0
    }
    
    fileprivate func removeContentOpacity() {
        self.opacityView.layer.opacity = 0.0
    }
    

    fileprivate func addContentOpacity() {
        self.opacityView.layer.opacity = Float(self.options.contentViewOpacity)
    }
    
    fileprivate func disableContentInteraction() {
        self.mainContainerView.isUserInteractionEnabled = false
    }
    
    fileprivate func enableContentInteraction() {
        self.mainContainerView.isUserInteractionEnabled = true
    }
    
    /*private func setOpenWindowLevel() {
        if (self.options.hideStatusBar) {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }*/
    
    fileprivate var _hidden : Bool = false
    func hideStatusBar(_ hidden : Bool)
    {
        _hidden = hidden
        
        if self.responds(to: #selector(UIViewController.setNeedsStatusBarAppearanceUpdate))
        {
            self.setNeedsStatusBarAppearanceUpdate()
            //self.performSelector(Selector("setNeedsStatusBarAppearanceUpdate"))
        }
    }
    
    override var prefersStatusBarHidden : Bool
    {
        return _hidden
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setCloseWindowLebel() {
        if (self.options.hideStatusBar) {
            DispatchQueue.main.async(execute: {
                if let window = UIApplication.shared.keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }
    
    fileprivate func setUpViewController(_ taretView: UIView, targetViewController: UIViewController?) {
        if let viewController = targetViewController {
            self.addChildViewController(viewController)
            viewController.view.frame = taretView.bounds
            taretView.addSubview(viewController.view)
            viewController.didMove(toParentViewController: self)
        }
    }
    
    
    fileprivate func removeViewController(_ viewController: UIViewController?) {
        if let _viewController = viewController {
            _viewController.willMove(toParentViewController: nil)
            _viewController.view.removeFromSuperview()
            _viewController.removeFromParentViewController()
        }
    }
    
    func closeLeftNonAnimation(){
        self.setCloseWindowLebel()
        let finalXOrigin: CGFloat = self.leftMinOrigin()
        var frame: CGRect = self.leftContainerView.frame;
        frame.origin.x = finalXOrigin
        self.leftContainerView.frame = frame
        self.opacityView.layer.opacity = 0.0
        self.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.removeShadow(self.leftContainerView)
        self.enableContentInteraction()
    }
    
    func closeRightNonAnimation(){
        self.setCloseWindowLebel()
        let finalXOrigin: CGFloat = self.view.bounds.width
        var frame: CGRect = self.rightContainerView.frame
        frame.origin.x = finalXOrigin
        self.rightContainerView.frame = frame
        self.opacityView.layer.opacity = 0.0
        self.mainContainerView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        self.removeShadow(self.rightContainerView)
        self.enableContentInteraction()
    }
    
    //pragma mark – UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    
        let point: CGPoint = touch.location(in: self.view)
        
        if gestureRecognizer == self.leftPanGesture {
            return self.slideLeftForGestureRecognizer(gestureRecognizer, point: point)
        } else if gestureRecognizer == self.rightPanGesture {
            if !isTagetViewController() {
                return false
            }
            return self.slideRightViewForGestureRecognizer(gestureRecognizer, withTouchPoint: point)
        } else if gestureRecognizer == self.leftTapGetsture {
            return self.isLeftOpen() && !self.isPointContainedWithinLeftRect(point)
        } else if gestureRecognizer == self.rightTapGesture {
            return self.isRightOpen() && !self.isPointContainedWithinRightRect(point)
        }
        
        return true
    }
    
    fileprivate func slideLeftForGestureRecognizer( _ gesture: UIGestureRecognizer, point:CGPoint) -> Bool{
        
        var slide = self.isLeftOpen()
        slide = self.options.panFromBezel && self.isLeftPointContainedWithinBezelRect(point)
        return slide
    }
    
    fileprivate func isLeftPointContainedWithinBezelRect(_ point: CGPoint) -> Bool{
        //var leftBezelRect: CGRect = CGRect.zero
        //var tempRect: CGRect = CGRect.zero
        let bezelWidth: CGFloat = self.options.leftBezelWidth
        let leftBezelRect = self.view.bounds.divided(atDistance: bezelWidth, from: CGRectEdge.minXEdge).slice
        //CGRectDivide(self.view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectEdge.minXEdge)
        return leftBezelRect.contains(point)
    }
    
    fileprivate func isPointContainedWithinLeftRect(_ point: CGPoint) -> Bool {
        return self.leftContainerView.frame.contains(point)
    }
    
    
    
    fileprivate func slideRightViewForGestureRecognizer(_ gesture: UIGestureRecognizer, withTouchPoint point: CGPoint) -> Bool {
        
        var slide: Bool = self.isRightOpen()
        slide = self.options.rightPanFromBezel && self.isRightPointContainedWithinBezelRect(point)
        return slide
    }
    
    fileprivate func isRightPointContainedWithinBezelRect(_ point: CGPoint) -> Bool {
        let rightBezelRect: CGRect = CGRect(x: 0, y: 0, width: self.options.rightBezelWidth, height: self.view.bounds.height)
        //var tempRect: CGRect = CGRectZero
        //CGFloat bezelWidth = self.rightContainerView.frame.size.width;
        //let bezelWidth: CGFloat = CGRectGetWidth(self.view.bounds) - self.options.rightBezelWidth
        
        //CGRectDivide(self.view.bounds, &tempRect, &rightBezelRect, bezelWidth, CGRectEdge.MinXEdge)
        
        return rightBezelRect.contains(point)
    }
    
    fileprivate func isPointContainedWithinRightRect(_ point: CGPoint) -> Bool {
        return self.rightContainerView.frame.contains(point)
    }
    
}


extension UIViewController {

    func slideMenuController() -> SlideMenuController? {
        var viewController: UIViewController? = self
        while viewController != nil {
            if viewController is SlideMenuController {
                return viewController as? SlideMenuController
            }
            viewController = viewController?.parent
        }
        return nil;
    }
    
    func addLeftBarButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.toggleLeft))
        self.navigationItem.leftBarButtonItem = leftButton;
    }
    
    func addRightBarButtonWithImage(_ buttonImage: UIImage) {
        let rightButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(UIViewController.toggleRight))
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
    func toggleLeft() {
        self.slideMenuController()?.toggleLeft()
    }

    func toggleRight() {
        self.slideMenuController()?.toggleRight()
    }
    
    func openLeft() {
        self.slideMenuController()?.openLeft()
    }
    
    func openRight() {
        self.slideMenuController()?.openRight()    }
    
    func closeLeft() {
        self.slideMenuController()?.closeLeft()
    }
    
    func closeRight() {
        self.slideMenuController()?.closeRight()
    }
    
    // Please specify if you want menu gesuture give priority to than targetScrollView
    func addPriorityToMenuGesuture(_ targetScrollView: UIScrollView) {
        if let slideControlelr = self.slideMenuController() {
            if let recognizers =  slideControlelr.view.gestureRecognizers {
                for recognizer in recognizers {
                    if recognizer is UIPanGestureRecognizer {
                        targetScrollView.panGestureRecognizer.require(toFail: recognizer)
                    }
                }
            }
        }
    }
    
    
    func willAppear(_ source : Int)
    {
        
    }
    
    func didAppear(_ source : Int)
    {
        
    }
    
    func willDisappear(_ to : Int)
    {
        
    }
    
}

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
