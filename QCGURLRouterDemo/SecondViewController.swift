//
//  SecondViewController.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import QCGURLRouter

class SecondViewController: UIViewController ,QCGURLReceiver{

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
        self.view.backgroundColor = UIColor.white
        self.title = "第二个页面"
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 500))
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = UIColor.black
        label.center = self.view.center
        self.view.addSubview(label)
        if let text = dic?["text"] as? String {
            label.text = text
        }
        
        let button = UIButton(frame: CGRect(x: 0, y: 100, width: 100, height: 30))
        button.setTitle("退出", for: .normal)
        button.backgroundColor = UIColor.gray
        button.addTarget(self, action: #selector(dismissVc), for: .touchUpInside)
        self.view.addSubview(button)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("second willappear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("second didappear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("second willdisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("second disappear")
    }
    
    deinit {
        print("second release")
    }

}
