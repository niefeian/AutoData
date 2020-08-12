//
//  Api.swift
//
//  Created by admin on 2019/7/16.
//  Copyright © 2019 聂飞安. All rights reserved.
//
import UIKit
import NFANetwork
public var isDebug = false


open class Api {
   
    public static let POST = "POST"
    public static let GET = "GET"
    public static var GETHOST = ""
    public static var HOST =  ""
    public static var WEB_HOST =  ""
    public static var DebugHOST =  ""
    public static var DebugWEB_HOST =  ""
    public static var server =  ""
    public static var hiddenfunc =  ""
    public static var port =  ""
    public static var cginame =  ""
    public static var IP =  ""
    public static var bodyType : HTTP_BODY_TYPE = .飞COM{
        didSet{
            if bodyType == .飞COM {
                successCod = "flag"
            }else if bodyType == .天COM {
                successCod = "status"
            }
        }
    }
    //根据内定的规则去写
    public static var appVersion  = "1"//应用版本

    public static var successCod = "flag"
    
    public class func WebHost() -> String {
       if isDebug {
           return DebugWEB_HOST
       }
       return WEB_HOST
    }

    public class func BaseHost() -> String {
       if isDebug {
           return DebugHOST
       }
       return HOST
    }


    public class func Web_PREFIX(_ url : String) -> String {
       if !url.hasPrefix("http") {
           return (WebHost() + url)
       }
       return url
    }

    public static var lastAddition = false //如果这个开启，接口将采用host + api 

    public static var commonPara : [String:String]!
}
