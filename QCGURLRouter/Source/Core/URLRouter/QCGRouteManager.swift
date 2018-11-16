//
//  QCGRouteManager.swift
//  QCGURLRouter
//
//  Created by zhangyr on 2016/11/18.
//  Copyright © 2016年 quchaogu. All rights reserved.
//

import UIKit

class QCGRouteManager: NSObject {
    ///share instance
    static let shareManager : QCGRouteManager = QCGRouteManager()
    /// type of url callback block
    typealias URLHandler = (Dictionary<String, Any>?) -> ()
    /// typealias of url info tuple
    typealias HandlerIntent = (handle: URLHandler? , intent: QCGIntent?)
    /// the dictionary save all registers
    private var registerMap : Dictionary<String , HandlerIntent> = Dictionary()
    
    
    func register(url: URL, receiver aClass: QCGURLReceiver.Type?) -> Bool {
        return insert(url: url, aClass: aClass)
    }
    
    func register(url: URL, handler aHandler: @escaping URLHandler) -> Bool {
        return insert(url: url, handler: aHandler)
    }
    
    func find(url: URL) -> HandlerIntent? {
        return registerMap[QCGPathUtil.getRelativePath(for: url)]
    }
    
    func insert(url: URL, aClass: QCGURLReceiver.Type?) -> Bool {
        if let hIntent = find(url: url) {
            if let intent = hIntent.intent {
                intent.receiver = aClass
            }else{
                registerMap[QCGPathUtil.getRelativePath(for: url)] = (hIntent.handle,QCGIntent(aClass: aClass))
            }
        }else{
            registerMap[QCGPathUtil.getRelativePath(for: url)] = (nil,QCGIntent(aClass: aClass))
        }
        return true
    }
    
    func insert(url: URL, handler: @escaping URLHandler) -> Bool {
        if let hIntent = find(url: url) {
            registerMap[QCGPathUtil.getRelativePath(for: url)] = (handler, hIntent.intent)
        }else{
            let intent = QCGIntent(aClass: nil)
            intent.params = QCGPathUtil.getParams(for: url)
            registerMap[QCGPathUtil.getRelativePath(for: url)] = (handler, intent)
        }
        return true
    }
    
    @discardableResult
    func update(url: URL,
                navi: UINavigationController.Type?,
                mode: QCGVCDisplayMode,
                param: Dictionary<String, Any>? = nil) -> Bool{
        if let hIntent = find(url: url) {
            if let intent = hIntent.intent {
                intent.navigation = navi
                switch mode {
                case .present:
                    intent.displayMode = QCGPresentedDisplay()
                    break
                case .push:
                    intent.displayMode = QCGPushDisplay()
                    break
                default:
                    intent.displayMode = QCGDrawDisplay()
                    break
                }
                var params = (QCGPathUtil.getParams(for: url) ?? param) ?? Dictionary<String, Any>()
                params.updateValue("1", forKey: mode.rawValue)
                intent.params = params
                return true
            }
        }
        return false
    }
    
    
}
