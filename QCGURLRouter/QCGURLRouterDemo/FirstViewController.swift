//
//  FirstViewController.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import QCGURLRouter

class FirstViewController: UIViewController ,QCGURLReceiver{

    private var dic : Dictionary<String, Any>?
    
    required init(parameters: Dictionary<String, Any>?) {
        super.init(nibName: nil, bundle: nil)
        dic = parameters
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weak var weakSelf = self
        weakSelf?.title = "第一个页面"
        weakSelf?.view.backgroundColor = UIColor.blue
        weakSelf?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "退出", style: UIBarButtonItemStyle.plain, target: weakSelf, action: #selector(FirstViewController.dismissVc))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("willAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("didAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("willDisAppear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("didDisAppear")
    }
    
    @objc func dismissVc() {
        if let _ = dic?[QCGVCDisplayMode.push.rawValue] {
            _ = self.navigationController?.popViewController(animated: true)
        }else if let _ = dic?[QCGVCDisplayMode.present.rawValue] {
            self.dismiss(animated: true, completion: nil)
        }else{
            self.turnbackViewController(animated: true)
        }
    }
    
    deinit {
        print("销毁")
    }

}
