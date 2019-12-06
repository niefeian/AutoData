//
//  HttpUtil.swift
//  iOSUtils
//
//  Created by 聂飞安 on 2019/6/10.
//  Copyright © 2019 聂飞安. All rights reserved.
//

import UIKit
import NFAToolkit
import NFANetwork
import NFASQLiteDB
import AutoModel

public class HttpUtil {
    
    open class func POST(_ url : String, params : Dictionary<String, String>?,  keys : [String]?  = nil, models : [AnyClass]?  = nil , ignoreSign : Bool = false, insteadOss : Bool = false, closeLoadingAnimate : Bool = true, showErrorMsg : Bool = true, errorCB : CB? = nil , callback : @escaping CBWithParam) {
        if Api.BaseHost() == ""  && !url.hasPrefix("http"){
            getHost(cb: {
                requestHttp(url, host: Api.BaseHost(), method:  Api.POST, params: params, keys: keys, models: models, ignoreSign: ignoreSign, insteadOss: insteadOss, closeLoadingAnimate: closeLoadingAnimate, showErrorMsg: showErrorMsg, callback: callback, errorCB: errorCB)
            })
        }else{
            requestHttp(url, host: Api.BaseHost(), method:  Api.POST, params: params, keys: keys, models: models, ignoreSign: ignoreSign, insteadOss: insteadOss, closeLoadingAnimate: closeLoadingAnimate, showErrorMsg: showErrorMsg, callback: callback, errorCB: errorCB)
        }
    }
    
    
    // GET 请求：异步
    open class func GET(_ url : String, params : Dictionary<String, String>? , noAutoParams : Bool = false, callback : @escaping CBWithParam) {
        if Api.BaseHost() == "" && !url.hasPrefix("http"){
            getHost(cb: {
              requestHttp(url, host: Api.BaseHost(), method : Api.GET, params : params,noAutoParams:false, callback : callback)
            })
        }else{
            requestHttp( url, host: Api.BaseHost(), method : Api.GET, params : params,noAutoParams:noAutoParams, callback : callback)
        }
    }
    
    open class func getHost(cb:@escaping CB) {
        HttpUtil.GET(Api.GETHOST, params: nil,noAutoParams:true) { (data) in
            if let dic = data as? NSDictionary {
               //这边后端下发规则自定义 配置域名
            }
        }
    }
 
    
    private class func requestHttp(_ baseurl : String, host : String, backUpUrl : String? = nil, method : String?, params : Dictionary<String, String>?, noAutoParams : Bool = false , keys : [String]?  = nil, models : [AnyClass]?  = nil  , ignoreSign : Bool = false, insteadOss : Bool = false, closeLoadingAnimate : Bool = true, showErrorMsg : Bool = true, callback : @escaping (AnyObject?) -> Void , errorCB : CB? = nil){
        
        if !ReachabilityNotificationView.getIsReachable(){
            return
        }
        
        var fullUrl = ""
        var parameters: Dictionary<String, String> = Dictionary()
        if noAutoParams || baseurl.hasPrefix("http"){
            fullUrl = baseurl
        }else{
            if params != nil {
                for (key, value) in params! {
                    parameters[key] = value
                }
            }
            if Api.commonPara != nil {
                for (key, value) in Api.commonPara!{
                    parameters[key] = value
                }
            }
            parameters["command"] = baseurl
        }
        
        if  let nsurl = URL(string: fullUrl){
            let request : RequestUtil = RequestUtil(url: nsurl)
            request.method = (method == nil ? Api.GET : method!)
            request.parameters =  parameters
            request.loadWithCompletion { response, json, error in
                if let actualError = error {
                    print(actualError)
                    DispatchQueue.main.async(execute: {
                         errorCB?()
                    })
                }else if let data = json , data.count != 0 {
                    #if DEBUG
                    let content = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    print(content ?? "")
                    #endif
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        if insteadOss {
                            DispatchQueue.main.async(execute: {
                                callback(jsonData)
                            })
                        } else {
                            if let success =  jsonData["flag"] as? String , success == "1" {
                                if let  dataModels = models , let dataKeys = keys , dataModels.count == dataKeys.count {
                                    var dataObj = [String : AnyObject]()
                                    for i in 0 ..< dataKeys.count {
                                        let key = dataKeys[i]
                                        if key == "-saveJosn"{
                                            SQLiteUtils.saveJosn(jsonData, type: "\(dataModels[i])")
                                        }else if key.contains("->"){
                                            let array = key.components(separatedBy: "->")
                                            //二级解析
                                            var dic = jsonData
                                            for i in 0 ..< array.count - 1{
                                                dic = jsonData[array[i]] as? NSDictionary ?? NSDictionary()
                                            }
                                            if let arr = dic[array.last ?? ""] as? [NSDictionary]{
                                                dataObj[dataKeys[i]] =  analysisList(arr, objClass: dataModels[i]) as AnyObject
                                            }else if let dic =  dic[array.last ?? ""] as? NSDictionary {
                                                if let obj = analysisData(dic, objClass: dataModels[i]){
                                                    dataObj[dataKeys[i]] = obj
                                                }
                                            }
                                            
                                        }else if let arr = jsonData[dataKeys[i]] as? [NSDictionary]{
                                            dataObj[dataKeys[i]] =  analysisList(arr, objClass: dataModels[i]) as AnyObject
                                        }else if let dic =  jsonData[dataKeys[i]] as? NSDictionary {
                                            if let obj = analysisData(dic, objClass: dataModels[i]){
                                                dataObj[dataKeys[i]] = obj
                                            }
                                        }else{
                                            printLog("无法解析的数据类型呢")
                                        }
                                    }
                                    DispatchQueue.main.async(execute: {
                                        callback(dataObj as AnyObject)
                                    })
                                }else{
                                    DispatchQueue.main.async(execute: {
                                       callback(jsonData)
                                    })
                                }
                             
                            } else {
                                if method == Api.GET {
                                    DispatchQueue.main.async(execute: {
                                        callback(jsonData)
                                    })
                                }else{
                                    DispatchQueue.main.async(execute: {
                                        errorCB?()
                                    })
                                }
                            }
                        }
                    } catch let e{
                        printLog(e)
                        DispatchQueue.main.async(execute: {
                            errorCB?()
                        })
                    }
                }else{
                    DispatchQueue.main.async(execute: {
                        errorCB?()
                    })
                }
            }
        }else{
           printLog("链接不存在")
        }
    }
    
    
    class func analysisList(_ array : [NSDictionary] , objClass : AnyClass ) -> [AnyObject] {
        var objArray = [AnyObject]()
        if let classType = NSClassFromString(NSStringFromClass(objClass)) as? BaseModel.Type {
            for dic in array {
                objArray.append(classType.init(dic))
            }
        }
        return objArray
    }
    
    class func analysisData(_ dic : NSDictionary , objClass : AnyClass ) -> AnyObject? {
        if let classType = NSClassFromString(NSStringFromClass(objClass)) as? BaseModel.Type {
            return classType.init(dic)
        }
       return nil
    }
    
    
    // url的参数，主要针对同步请求的，主动进行转换
    open class func getUrlParam(_ params : Dictionary<String, AnyObject>, isPost : Bool = true) -> Data {
        var result = isPost ? "" : "?"
        var firstPass = true
        for (key, value) in params {
            let encodedKey: NSString = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! as NSString
            
            let encodedValue: String = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            result += firstPass ? "\(encodedKey)=\(encodedValue)" : "&\(encodedKey)=\(encodedValue)"
            firstPass = false
        }
        return result.data(using: String.Encoding.utf8, allowLossyConversion: true)!
    }
    
    // 异步加载数据
    open class func loadBySync(_ url : String, cb : @escaping CBWithParam) {
        let session = URLSession(configuration: URLSessionConfiguration.default)
        if let nsURL = URL(string: url) {
            session.dataTask(with: nsURL, completionHandler: {
                (response: Data?, data: URLResponse?, error: NSError?) in
                if (error == nil) {
                    if response != nil {
                        DispatchQueue.main.async(execute: {
                            cb(response! as AnyObject?)
                        })
                    }
                }
                
                session.finishTasksAndInvalidate()
                } as! (Data?, URLResponse?, Error?) -> Void).resume()
        }
    }
}