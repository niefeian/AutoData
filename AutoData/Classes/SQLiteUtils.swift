//
//  SQLiteUtils.swift
//  AutoData
//
//  Created by 聂飞安 on 2019/11/6.
//

import UIKit
import AutoModel
import NFAToolkit
import NFASQLiteDB

public func printLogInsatll<T>(_ message : T, file : String = #file, method : String = #function, line : Int = #line) {
    #if DEBUG
    print(file)
    print("\(line),\(method):\n\(message)")
    SQLiteUtils.insetApplog("\(file)\n\(line),\(method):\n\(message)")
    #endif
}


open class SQLiteUtils {
    
    public class func insetApplog(_ json : String ){
        let param = NSMutableArray()
        param.add(Tools.getUUID())
        param.add(json)
        let nowDate = Date()
        param.add("\(nowDate.timeIntervalSince1970)")
        param.add("\(DateUtil.dateTimeToStr(nowDate))")
        let insert = "insert into applog(id , log , time_stamp  , startTime) values(?,?,?,?)"
        _ = SQLiteDB.sharedInstance().execute(insert, parameters: param)
    }
    
    public class func sleApplog(){
        let insert = "select * from  applog  order by time_stamp desc limit 0,1000; "
        let rows = SQLiteDB.sharedInstance().query(insert)
        for row in rows{
            print(row.getStringColumnData("log"))
        }
        
    }
    
   public class func insetBaseModel(_ vo : BaseModel , key : String , type : String) {
        var json : String = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: vo.toJosn(), options: JSONSerialization.WritingOptions.prettyPrinted)
            let strJson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            json = strJson as String? ?? ""
        }catch _ {
            
        }
        
        let param = NSMutableArray()
        param.add(Tools.getUUID())
        param.add(json)
        param.add(key)
        param.add(type)
        let insert = "insert into josn_table (id , json , key , type) values(?,?,?,?)"
        _ = SQLiteDB.sharedInstance().execute(insert, parameters: param)
    }
    
    public class func insetError(_ info : String  , url : String , desc : String = "") {
           let param = NSMutableArray()
           param.add(Tools.getUUID())
           param.add(info)
           param.add(url)
          param.add(desc)
           let insert = "insert into http_error (id , info  , url  , desc) values(?,?,?,?)"
           _ = SQLiteDB.sharedInstance().execute(insert, parameters: param)
           
    }
    
    //因为我们是根据出生算的
    public class func saveJosn(_ map : NSDictionary , type : String) {
        var json : String = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: map, options: JSONSerialization.WritingOptions.prettyPrinted)
            let strJson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            json = strJson as String? ?? ""
        }catch _ {
            
        }
        if selectBaseModel(key: Api.appVersion + type){
            let update = "update josn_table set json = ?  where key = ?"
            let param = NSMutableArray()
            param.add(json)
            param.add(Api.appVersion + type)
            _ = SQLiteDB.sharedInstance().execute(update, parameters: param)
        }else{
            let param = NSMutableArray()
            param.add(Tools.getUUID())
            param.add(json)
            param.add(Api.appVersion + type)
            param.add(type)
            let insert = "insert into  josn_table (id , json , key , type) values(?,?,?,?)"
            _ = SQLiteDB.sharedInstance().execute(insert, parameters: param)
        }
    }
    
    public class func getJosn(_ type : String)->String?{
        let sql = "select * from josn_table where key = ? "
        let param = NSMutableArray()
        param.add(Api.appVersion + type)
        return SQLiteDB.sharedInstance().query(sql,parameters: param).first?.getStringColumnData("json")
    }
    
    public class func selectBaseModel(key : String) -> Bool{
        let sql = "select * from josn_table where key = ? "
        let param = NSMutableArray()
        param.add(key)
        return SQLiteDB.sharedInstance().query(sql,parameters: param).count > 0
    }
    
    public class func selectBaseModel(type : String) -> [SQLRow]{
        let sql = "select * from josn_table where type = ? "
        let param = NSMutableArray()
        param.add(type)
        return SQLiteDB.sharedInstance().query(sql,parameters: param)
    }
    
    public class func deletBaseModel(key : String){
        let sql = "delete  from josn_table where key = ? "
        let param = NSMutableArray()
        param.add(Api.appVersion + key)
        SQLiteDB.sharedInstance().execute(sql,parameters: param)
    }
    
}
