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
    
    
    open class func POST(_ url : String, params : Dictionary<String, String>?,  keys : [String]?  = nil, models : [AnyClass]?  = nil , ignoreSign : Bool = false, insteadOss : Bool = false , inSave : Bool = false , getLocal : Bool = false , closeLoadingAnimate : Bool = true, showErrorMsg : Bool = false , bodyData : Data? = nil,  headers: Dictionary<String, String>? = nil, errorCB : CBWithParam? = nil , callback : @escaping CBWithParam) {
        /*
        if Api.BaseHost() == ""  && !url.hasPrefix("http"){
            getHost(cb: {
                requestHttp(url, host: Api.BaseHost(), method:  Api.POST, params: params, keys: keys, models: models,  insteadOss: insteadOss,inSave: inSave, getLocal: getLocal  , isReconnection: closeLoadingAnimate, showErrorMsg: showErrorMsg, bodyData:bodyData, callback: callback, errorCB: errorCB)
            })
        }else{
 */
            requestHttp(url, host: Api.BaseHost(), method:  Api.POST, params: params, keys: keys, models: models,  insteadOss: insteadOss,inSave: inSave, getLocal: getLocal  , isReconnection: closeLoadingAnimate, showErrorMsg: showErrorMsg, bodyData:bodyData, headers: headers, callback: callback, errorCB: errorCB)
//        }
    }
    
    
    // GET 请求：异步
    open class func GET(_ url : String, params : Dictionary<String, String>? , noAutoParams : Bool = false , inSave : Bool = false , bodyData : Data? = nil ,  headers: Dictionary<String, String>? = nil, callback : @escaping CBWithParam) {
        /*
        if Api.BaseHost() == "" && !url.hasPrefix("http"){
            getHost(cb: {
                requestHttp(url, host: Api.BaseHost(), method : Api.GET, params : params,noAutoParams:false, inSave: inSave, getLocal: false , bodyData:bodyData,callback : callback)
            })
        }else{
            */
        requestHttp( url, host: Api.BaseHost(), method : Api.GET, params : params,noAutoParams:noAutoParams, inSave: inSave, getLocal: false , bodyData:bodyData, headers: headers, callback : callback)
//        }
    }
    /*
    open class func getHost(cb:@escaping CB) {

        HttpUtil.GET(Api.GETHOST, params: nil,noAutoParams:true) { (data) in
           if let dic = data as? NSDictionary
           {
                Api.server = dic.string(forKey: "server")
                Api.hiddenfunc = dic.string(forKey: "hiddenfunc")
              if let dics = dic.object(forKey: "webdomain") as? [String] , dics.count > 0
              {
                    Api.WEB_HOST  = "http://" + (dics.last ?? "") + "/v1/page/"
              }
            
            if let dics = dic.object(forKey: "api") as? [NSDictionary] , dics.count > 0
              {
                Api.HOST = "http://" + (dics.last?.string(forKey: "ip") ?? "") + "/v1/index.php"
                Api.cginame = dics.last?.string(forKey: "cginame") ?? "api.feifeiapp.com"
                Api.port = dics.last?.string(forKey: "port") ?? "6220"
                Api.IP = dics.last?.string(forKey: "ip") ?? "api.feiyo.net"
                cb()
              }
           }
            
       }
    }
 */
    
    //获得历史数据
    public class func getHistoryData(_ baseurl : String , params : Dictionary<String, String>? = nil , keys : [String]?  = nil, models : [AnyClass]?  = nil  , callback : @escaping (AnyObject?) -> Void , errorCB : CBWithParam? = nil){
        if let josn = SQLiteUtils.getJosn(baseurl) , josn.count > 0 ,  let jsonData = josn.stringToDic()
        {
            if let  dataModels = models , let dataKeys = keys , dataModels.count == dataKeys.count {
                callback(analysisdataModels(jsonData: jsonData as NSDictionary, dataKeys: dataKeys, dataModels: dataModels) as AnyObject)
            }
        }else{
            errorCB?(nil)
        }
    }
    
    public class func deleteHistoryData(_ baseurl : String , params : Dictionary<String, String>? = nil){
        SQLiteUtils.deletBaseModel(key: baseurl)
    }
    
    public class func saveJosnHistoryData(_ baseurl : String , params : NSDictionary){
        SQLiteUtils.saveJosn(params, type: baseurl)
    }
     
    private class func requestHttp(_ baseurl : String, host : String, backUpUrl : String? = nil, method : String?, params : Dictionary<String, String>?, noAutoParams : Bool = false , keys : [String]?  = nil, models : [AnyClass]?  = nil  ,insteadOss : Bool = false , inSave : Bool , getLocal : Bool , isReconnection : Bool = true, showErrorMsg : Bool = true , bodyData : Data? ,  headers: Dictionary<String, String>?, callback : @escaping (AnyObject?) -> Void , errorCB : CBWithParam? = nil){
        
        if inSave && getLocal
        {
            if let josn = SQLiteUtils.getJosn(baseurl) ,  let jsonData = josn.stringToDic()
            {
               if let  dataModels = models , let dataKeys = keys , dataModels.count == dataKeys.count
               {
                    callback(analysisdataModels(jsonData: jsonData as NSDictionary, dataKeys: dataKeys, dataModels: dataModels) as AnyObject)
                }
            }
        }
        
        if !ReachabilityNotificationView.getIsReachable()
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FloatTips"), object: "当前网络不稳定")
            errorCB?(nil)
            return
        }
        
        
        var fullUrl = ""
        var parameters: Dictionary<String, String> = Dictionary()
       
        if noAutoParams || baseurl.hasPrefix("http")
        {
            fullUrl = baseurl
        }
        else
        {
            if params != nil
            {
                for (key, value) in params!
                {
                    parameters[key] = value
                }
            }
            
            if Api.commonPara != nil
            {
                for (key, value) in Api.commonPara!
                {
                    parameters[key] = value
                }
            }
            
            if Api.bodyType == .飞COM
            {
               parameters["command"] = baseurl
            }
            else if Api.bodyType == .飞2COM
            {
               parameters["m"] = baseurl
            }
            fullUrl = host
        }
        
        if Api.lastAddition
        {
            fullUrl += baseurl
        }
        
        if  let nsurl = URL(string: fullUrl)
        {
            let request : RequestUtil = RequestUtil(url: nsurl)
            request.method = (method == nil ? Api.GET : method!)
            request.parameters =  parameters
            request.bodyType = Api.bodyType
            request.bodyData = bodyData
            if headers != nil
            {
                request.headers = headers!
            }
            request.loadWithCompletion { response, json, error in
                
                if let actualError = error {
                    DispatchQueue.main.async(execute: {
                        if isReconnection
                        {
                            requestHttp(baseurl, host: host, method: method, params: params, keys: keys, models: models,  insteadOss: insteadOss,inSave: inSave, getLocal: getLocal  , isReconnection: false, showErrorMsg: showErrorMsg, bodyData : bodyData, headers: headers, callback: callback, errorCB: errorCB)
                        }
                        else
                        {
                             errorCB?(actualError)
                        }
                    })
                    #if DEBUG
//                        print(actualError.localizedDescription)
//                       print(Api.HOST + baseurl)
//                        SQLiteUtils.insetError(actualError.localizedDescription,url: Api.HOST + baseurl)
                    #endif
                }
                else if let data = json , data.count != 0
                {
                    if isDebug
                    {
                        let content = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        print(content ?? "")
                    }
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
                        if insteadOss {
                            DispatchQueue.main.async(execute: {
                                callback(jsonData)
                            })
                        } else {
                            if  jsonData.string(forKey: Api.successCod)  == "1" || jsonData.bool(forKey:  Api.successCod){
                                if inSave {
                                    SQLiteUtils.saveJosn(jsonData, type: baseurl)
                                }
                                if let  dataModels = models , let dataKeys = keys , dataModels.count == dataKeys.count {
                                    DispatchQueue.main.async(execute: {
                                        callback(analysisdataModels(jsonData: jsonData, dataKeys: dataKeys, dataModels: dataModels) as AnyObject)
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
                                        if showErrorMsg {
                                            if let debug =  jsonData["debug"] as? String{
                                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FloatTips"), object: debug)
                                            }
                                        }
                                        let content = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                                        errorCB?(content)
                                    })
                                }
                            }
                        }
                    } catch let e{
                        #if DEBUG
                        printLog(e)
//                        SQLiteUtils.insetError(e.localizedDescription,url: Api.HOST + baseurl)
                        #endif
                        DispatchQueue.main.async(execute: {
                            errorCB?(e as AnyObject)
                        })
                    }
                }else{
                    #if DEBUG
//                    SQLiteUtils.insetError("数据无法解析",url: Api.HOST + baseurl)
                    #endif
                    DispatchQueue.main.async(execute: {
                        errorCB?(nil)
                    })
                }
                            }
        }else{
           printLog("链接不存在")
        }
    }
    
    class public func analysisdataModels(jsonData : NSDictionary , dataKeys : [String], dataModels : [AnyClass])  -> [String : AnyObject]{
        var dataObj = [String : AnyObject]()
        for i in 0 ..< dataKeys.count {
            let key = dataKeys[i]
            if key.contains("->"){
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
        return dataObj
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
