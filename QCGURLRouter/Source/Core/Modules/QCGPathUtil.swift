//
//  QCGPathUtil.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

class QCGPathUtil: NSObject {
    
    class func getRelativePath(for url: URL) -> String {
        if isNetScheme(for: url) {
            return url.relativePath
        }else{
            return url.absoluteString.components(separatedBy: "?").first ?? ""
        }
    }
    
    class func isNetScheme(for url: URL) -> Bool {
        return url.scheme != nil && url.scheme!.hasPrefix("http")
    }
    
    class func isNativePath(for url: URL) -> Bool {
        return url.host == nil || url.host!.contains(QCGURLRouter.shareInstance.host)
    }
    
    class func getParams(for url: URL) -> Dictionary<String,Any>? {
        var dic : Dictionary<String,Any>?
        if let query = url.query {
            dic = Dictionary<String, Any>()
            let paraArray = (query as NSString).components(separatedBy: "&")
            for p in paraArray {
                let para = (p as NSString).components(separatedBy: "=")
                if para.count == 2 {
                    let encodingStr = para[1]
                    dic?.updateValue(encodingStr.removingPercentEncoding ?? encodingStr, forKey: para[0])
                }
            }
        }
        return dic
    }
    
}
