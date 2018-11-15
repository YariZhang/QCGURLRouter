//
//  QCGPresentedDisplay.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

class QCGPresentedDisplay: NSObject ,QCGDisplay{
    
    func display(from vc: UIViewController, to desVc: UIViewController) {
        if let navi = desVc as? UINavigationController {
            vc.present(navi, animated: true, completion: nil)
        }else{
            let navi = UINavigationController(rootViewController: desVc)
            vc.present(navi, animated: true, completion: nil)
        }
    }
    
}
