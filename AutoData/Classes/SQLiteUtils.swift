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

open class SQLiteUtils {
    
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
        let insert = "insert into  head (id , json , key , type) values(?,?,?,?)"
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
        if selectBaseModel(key: Api.josnKey + type){
             let update = "update head set json = ?  where key = ?"
            let param = NSMutableArray()
               param.add(json)
            param.add(Api.josnKey)
            _ = SQLiteDB.sharedInstance().execute(update, parameters: param)
        }else{
            let param = NSMutableArray()
            param.add(Tools.getUUID())
            param.add(json)
            param.add(Api.josnKey + type)
            param.add(type)
            let insert = "insert into  head (id , json , key , type) values(?,?,?,?)"
            _ = SQLiteDB.sharedInstance().execute(insert, parameters: param)
        }
    }
    
    public class func getJosn(_ type : String)->String?{
        let sql = "select * from head where key = ? "
        let param = NSMutableArray()
        param.add(Api.josnKey + type)
        return SQLiteDB.sharedInstance().query(sql,parameters: param).first?.getStringColumnData("json")
    }
    
    public class func selectBaseModel(key : String) -> Bool{
        let sql = "select * from head where key = ? "
        let param = NSMutableArray()
        param.add(key)
        return SQLiteDB.sharedInstance().query(sql,parameters: param).count > 0
    }
    
    public class func selectBaseModel(type : String) -> [SQLRow]{
        let sql = "select * from head where type = ? "
        let param = NSMutableArray()
        param.add(type)
        return SQLiteDB.sharedInstance().query(sql,parameters: param)
    }
    
    public class func deletBaseModel(key : String){
        let sql = "delete  from head where key = ? "
        let param = NSMutableArray()
        param.add(key)
        SQLiteDB.sharedInstance().execute(sql,parameters: param)
    }
    
}
