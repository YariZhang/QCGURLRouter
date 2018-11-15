//
//  QCGIntent.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public class QCGIntent: NSObject {

    ///the class conform QCGURLReceiver
    public var receiver : QCGURLReceiver.Type?
    ///display mode
    public var displayMode : QCGDisplay = QCGPushDisplay()
    ///custom navigation controller
    public var navigation : UINavigationController.Type?
    ///parameters for receiver
    public var params : Dictionary<String ,Any>?
    
    public init(aClass: QCGURLReceiver.Type?) {
        self.receiver = aClass
    }
    
}
