//
//  VersionControl.swift
//  AutoData
//
//  Created by 聂飞安 on 2020/3/12.
//

import UIKit
import NFASQLiteDB

open class VersionControl {

  public  class func update() {
        
        let version = UserDefaults.standard.integer(forKey: "Constants.APP_CACHE.DB_VERSION")
        
        if version < 1 {
             updateVersion1()
        }
    
    if version < 2 {
         updateVersion2()
    }
        
        // 当前版本。为0即为app的1.0版本
    }
    
    class func updateVersion2() {
           _ = SQLiteDB.sharedInstance().execute("CREATE TABLE http_error(id VARCHAR(36) PRIMARY KEY NOT NULL , url VARCHAR(120)  , info json , desc VARCHAR(220) , startTime VARCHAR(40));")
           UserDefaults.standard.set(2, forKey: "Constants.APP_CACHE.DB_VERSION")
       }
    
     class func updateVersion1() {
        _ = SQLiteDB.sharedInstance().execute("CREATE TABLE josn_table(id VARCHAR(36) PRIMARY KEY NOT NULL , type VARCHAR(120) , key VARCHAR(100) , json VARCHAR(2000));")
        UserDefaults.standard.set(1, forKey: "Constants.APP_CACHE.DB_VERSION")
    }
}
