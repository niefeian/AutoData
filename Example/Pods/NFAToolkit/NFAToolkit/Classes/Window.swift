//
//  Window.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2019/11/6.
//

import UIKit

//进入异步线程
public func queueGlobalAsync(work : @escaping @convention(block) () -> Swift.Void){
   
    DispatchQueue.global().async {
        work()
    }
}

//进入主线程
public func queueMainAsync(work : @escaping @convention(block) () -> Swift.Void){
    DispatchQueue.main.async {
        work()
    }
}


public func AppWindow() ->UIWindow {
    if let delegate: UIApplicationDelegate = UIApplication.shared.delegate {
        if let window = delegate.window , window != nil {
            return window!
        }
    }
    
    return  UIApplication.shared.keyWindow ?? UIWindow()
}


public func AppViewController() -> UIViewController? {
    var viewController = AppWindow().rootViewController
    while(true) {
        if (viewController?.isKind(of: UITabBarController.self))! {
            viewController = (viewController as! UITabBarController).selectedViewController
        }else if (viewController?.isKind(of: UINavigationController.self))!{
            viewController = (viewController as! UINavigationController).visibleViewController
        }else if ((viewController?.presentedViewController) != nil){
            viewController =  viewController?.presentedViewController
        } else {
            break
        }
    }
    return viewController
}
