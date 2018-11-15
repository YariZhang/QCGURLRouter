//
//  AppDelegate.swift
//  QCGURLRouterDemo
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import QCGURLRouter

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        let rootVc = ViewController(parameters: nil)
        let naviVc = UINavigationController(rootViewController: rootVc)
        self.window?.rootViewController = naviVc
        registerController()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return QCGURLRouter.shareInstance.route(withUrl: url)
    }
    
    func registerController() {
        //QCGURLRouter.shareRouter.register(url: URL(string:"/quchaogu/first")!, receiver: FirstViewController.self)
        //QCGURLRouter.shareRouter.register(url: URL(string:"/quchaogu/second")!, receiver: SecondViewController.self)
        //try input quchaogu://quchaogu.com/quchaogu/second?text=this_is_a_extra_information in safari
        if let plistPath = Bundle.main.path(forResource: "Registers", ofType: "plist") {
            QCGURLRouter.shareInstance.register(fromPlist: plistPath)
        }
    
        QCGURLRouter.shareInstance.register(url: URL(string:"/quchaogu/alert")!, handler: {(params) in
            if let para = params {
                let alert = UIAlertView(title: para["title"] as? String, message: para["msg"] as? String, delegate: nil, cancelButtonTitle: "我知道了")
                alert.show()
            }
        })
    }


}

