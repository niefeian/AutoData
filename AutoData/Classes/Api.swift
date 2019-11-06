//
//  Api.swift
//
//  Created by admin on 2019/7/16.
//  Copyright © 2019 聂飞安. All rights reserved.
//
import UIKit

public var isDebug = false

open class Api {
   
    public static let POST = "POST"
    public static let GET = "GET"
    
    public static var GETHOST = ""
    public static var HOST =  ""
    public static var WEB_HOST =  ""
    public static var DebugHOST =  ""
    public static var DebugWEB_HOST =  ""
    
    class func WebHost() -> String {
        if isDebug {
            return DebugWEB_HOST
        }
        return WEB_HOST
    }
    
//    zw.flany.cn zw.feiyo.com
    public class func BaseHost() -> String {
        if isDebug {
            return DebugHOST
        }
        return HOST
    }
    
    
    class func Web_PREFIX(_ url : String) -> String {
        if !url.hasPrefix("http") {
            return (WebHost() + url)
        }
        return url
    }
    
    
    public static var commonPara : [String:String]!
    public static var josnKey : String = ""//这个是用来保存后端下发的数据的一种简易方式
}
