//
//  QCGPushDisplay.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

class QCGPushDisplay: NSObject ,QCGDisplay {

    func display(from vc: UIViewController, to desVc: UIViewController) {
        if let navi = vc as? UINavigationController {
            navi.pushViewController(desVc, animated: true)
        }else if let navi = vc.navigationController {
            navi.pushViewController(desVc, animated: true)
        }
    }
    
}
