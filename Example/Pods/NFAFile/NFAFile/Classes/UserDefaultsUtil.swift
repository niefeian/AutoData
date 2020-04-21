//
//  UserDefaultsUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//

import Foundation


public enum UserDefaultsStatus {
    case never , unfinish , finish
}

open class UserDefaultsUtils {
    
    /// 在分组中进行完结
    open class func finishInGroup(_ group : String, key : String , finish : Bool = true) {
        let groups = UserDefaults.standard.value(forKey: group)
        if groups == nil {
            let dic = NSMutableDictionary()
            dic.setValue(finish, forKey: key)
            UserDefaults.standard.set(dic, forKey: group)
        } else {
            let oldDic = groups as! NSDictionary
            let dic = NSMutableDictionary(dictionary: oldDic)
            dic.setValue(finish, forKey: key)
            UserDefaults.standard.set(dic, forKey: group)
        }
    }

    open class func getGroup(_ group : String, key : String) ->  UserDefaultsStatus{
           let groups = UserDefaults.standard.value(forKey: group)
           if groups == nil {
                return .never
           } else {
               let oldDic = groups as! NSDictionary
                if oldDic.object(forKey: key) as? Bool ?? false {
                    return .finish
                }else{
                    return .unfinish
                }
           }
       }
     
}
