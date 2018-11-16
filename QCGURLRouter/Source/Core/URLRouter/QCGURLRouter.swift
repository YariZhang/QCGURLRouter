//
//  QCGURLRouter.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public class QCGURLRouter: NSObject {
    
    //-------property------------
    
    /// instance of QCGURLRouter
    public static let shareInstance : QCGURLRouter = QCGURLRouter()
    /// type of url callback block
    public typealias URLHandler = (Dictionary<String, Any>?) -> ()
    /// manager for router
    private let manager : QCGRouteManager = QCGRouteManager.shareManager
    /// host for app
    public var host : String = "com"
    
    //--------base method--------
    /**
     Register url with a block.
     - parameter url: url identifier for registered block.
     - parameter handler: the block which needs to register.
     
     - returns: if it register successfully or not
    */
    @discardableResult
    public func register(url: URL, handler aHandler: @escaping URLHandler) -> Bool {
        return manager.register(url: url, handler: aHandler)
    }
    /**
     Route url to display a controller or call a block.
     - parameter url: url identifier for registered block or class.
     - parameter navigationController: display class with custom navigation controller.
     - parameter displayMode: UIViewController display mode.
     - parameter param: params for controller
     
     - returns: if url exists or not
    */
    @discardableResult
    public func route(withUrl url: URL,
                      navigationController navi: UINavigationController.Type?,
                      displayMode mode: QCGVCDisplayMode,
                      param: Dictionary<String, Any>? = nil) -> Bool {
        manager.update(url: url, navi: navi, mode: mode, param: param)
        if let hIntent = manager.find(url: url) , let handler = hIntent.handle {
            var dict: Dictionary<String, Any> = ["router_url": url]
            if let para = hIntent.intent?.params {
                for (k, v) in para {
                    dict.updateValue(v, forKey: k)
                }
            }
            handler(dict)
            return true
        }
        return false
    }
    
}

public extension QCGURLRouter {
    
    /**
     Register url with a class type.
     - parameter url: url identifier for registered class
     - parameter recriver: the class which needs to register
     
     - returns: if it register successfully or not
     */
    @discardableResult
    public func register(url: URL, receiver aClass: QCGURLReceiver.Type?) -> Bool {
        weak var weakSelf = self
        let cls = manager.register(url: url, receiver: aClass)
        let handler = manager.register(url: url, handler: { (params) in
            if let tmpUrl = params?["router_url"] as? URL {
                if let hIntent = weakSelf?.manager.find(url: tmpUrl) ,let intent = hIntent.intent {
                    let vc = intent.receiver?.init(parameters: intent.params)
                    if let tvc = vc as? UIViewController {
                        if let navi = intent.navigation {
                            let naviVc = navi.init(rootViewController: tvc)
                            intent.displayMode.display(from: UIApplication.currentController()!, to: naviVc)
                        }else{
                            intent.displayMode.display(from: UIApplication.currentController()!, to: tvc)
                        }
                    }
                }
            }
        })
        return cls && handler
    }
    /**
     Register multiple classes from a plist
     - parameter fromPlist: the plist file path

     - returns: if it registers successfully or not
    */
    @discardableResult
    public func register(fromPlist file: String) -> Bool {
        guard let registers = NSDictionary(contentsOfFile: file) else {
            return false
        }
        for (key, value) in registers {
            guard let url = key as? String, let className = value as? String else {
                return false
            }
            if let aClass = NSClassFromString(className) as? QCGURLReceiver.Type {
                register(url: URL(string: url)!, receiver: aClass)
            }
        }
        return true
    }
    /**
     Route url to display a controller or call a block for openURL.
     - parameter url: url identifier for registered block or class.
     
     - returns: if url exists or not
    */
    @discardableResult
    public func route(withUrl url: URL, param: Dictionary<String, Any>? = nil) -> Bool {
        return route(withUrl: url, navigationController: nil, displayMode: .push, param: param)
    }
    
}

private extension UIApplication {
    class func currentController(root: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navi = root as? UINavigationController {
            return currentController(root: navi.visibleViewController)
        }
        if let tabBar = root as? UITabBarController {
            if let selected = tabBar.selectedViewController {
                return currentController(root: selected)
            }
        }
        if let presented = root?.presentedViewController {
            return currentController(root: presented)
        }
        return root
    }
}
