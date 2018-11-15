//
//  QCGVCDisplayMode.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

/**
 Display mode
 */
public enum QCGVCDisplayMode : String {
    case push = "qcg_router_display_push"
    case present = "qcg_router_display_present"
    case draw = "qcg_router_display_draw"
}

public protocol QCGDisplay : NSObjectProtocol {
    func display(from vc: UIViewController, to desVc: UIViewController)
}
