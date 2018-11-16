//
//  ViewController.swift
//  QCGURLRouterDemo
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit
import QCGURLRouter

class ViewController: UIViewController ,QCGURLReceiver {
    
    private var dic : Dictionary<String, Any>?
    private let texts = ["执行block","跳转普通页面","跳转带参页面"]
    
    required init(parameters: Dictionary<String, Any>?) {
        super.init(nibName: nil, bundle: nil)
        dic = parameters
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.lightGray
        self.title = "首页"
        for i in 0 ... 2 {
            let button = UIButton(frame: CGRect(x: 100, y: 100 + CGFloat(i * (20 + 40)), width: UIScreen.main.bounds.width - 200, height: 40))
            button.backgroundColor = UIColor.red
            button.tag = i
            button.setTitle(texts[i], for: UIControlState.normal)
            button.addTarget(self, action: #selector(ViewController.buttonClick(btn:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(button)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("view will disappear")
    }

    @objc private func buttonClick(btn: UIButton) {
        
        switch btn.tag {
        case 0:
            let str = "/quchaogu/alert"
            if let s = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                QCGURLRouter.shareInstance.route(withUrl: URL(string: s)!, param: ["title": "提示", "msg": "这是一条提示信息"])
            }
            break
        case 1:
            let url = URL(string: "http://www.quchaogu.com/quchaogu/first")!
            if !QCGURLRouter.shareInstance.route(withUrl: url, navigationController: QCGNavigationController.self, displayMode: QCGVCDisplayMode.present) {
                print(url.absoluteString)
            }
            break
        default:
            QCGURLRouter.shareInstance.route(withUrl: URL(string: "http://quchaogu.com/quchaogu/second?text=this_is_a_test_parameter_string")!, navigationController: nil, displayMode: QCGVCDisplayMode.draw)
            break
        }
        
    }

}

