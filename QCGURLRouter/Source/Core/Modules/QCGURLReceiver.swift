//
//  QCGURLReceiver.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

public protocol QCGURLReceiver: class {
    // initialized with some parameters
    init(parameters : Dictionary<String , Any>?)
}
