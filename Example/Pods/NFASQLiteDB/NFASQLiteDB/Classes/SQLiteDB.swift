//
//  SQLiteDB.swift
//  TasksGalore
//
//  Created by Fahim Farook on 12/6/14.
//  Copyright (c) 2014 RookSoft Pte. Ltd. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

import SQLite3

let SQLITE_DATE = SQLITE_NULL + 1

private let SQLITE_STATIC = unsafeBitCast(0, to:sqlite3_destructor_type.self)
private let SQLITE_TRANSIENT = unsafeBitCast(-1, to:sqlite3_destructor_type.self)

public func getColumn(row : SQLRow, field : String) -> Any? {
    return nil
}

extension String {
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
                pos = distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
    
    func subString(start:Int, length:Int = -1)->String {
        var len = length
        if len == -1 {
            len = count - start
        }
        let st = index(startIndex, offsetBy:start)
        let en = index(st, offsetBy:len)
        let range = st ..< en
        return substring(with:range)
    }
    
    
}



// 获取某行某列数据

public func getColumnData(_ row : SQLRow, field : String) -> AnyObject?{
    return row.data[field] as AnyObject
}

public func getStringColumnData(_ row : SQLRow, field : String) -> String?{
    return row.data[field] as? String
}

public func getIntColumnData(_ row : SQLRow, field : String) -> Int?{
    return row.data[field] as? Int
}

public func getDoubleColumnData(_ row : SQLRow, field : String) -> Double?{
    return row.data[field] as? Double
}

open class SQLRow {
    open var data : [String:Any]!
    
    open func getColumnData(_ field : String) -> AnyObject? {
        return data[field] as AnyObject
    }
    
    open func getStringColumnData(_ field : String, defaultValue : String = "") -> String{
        return data[field] as? String ?? defaultValue
    }
    
    open  func getIntColumnData(_ field : String, defaultValue : Int = 0) -> Int{
        return data[field] as? Int ?? defaultValue
    }
    
     open func getDoubleColumnData(_ field : String, defaultValue : Double = 0) -> Double{
        return data[field] as? Double ?? defaultValue
    }
}

// MARK:- SQLiteDB Class - Does all the work
@objc(SQLiteDB)
open class SQLiteDB:NSObject {
    private static var instance : SQLiteDB? = nil
    let DB_NAME = "data.db"
    let QUEUE_LABEL = "SQLiteDB"
    
   open class func sharedInstance() -> SQLiteDB {
        if instance == nil {
            instance = SQLiteDB()
        }
        return instance!
    }
    
    private var db:OpaquePointer? = nil
    private var queue:DispatchQueue!
    private let fmt = DateFormatter()
    private var path:String!
    
    private override init() {
        super.init()
        // Set up for file operations
        let fm = FileManager.default
        //        let dbName = String(cString:DB_NAME)
        // Get path to DB in Documents directory
        var docDir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        // If macOS, add app name to path since otherwise, DB could possibly interfere with another app using SQLiteDB
        #if os(OSX)
            let info = Bundle.main.infoDictionary!
            let appName = info["CFBundleName"] as! String
            docDir = (docDir as NSString).appendingPathComponent(appName)
            
            // Create folder if it does not exist
            if !fm.fileExists(atPath:docDir) {
                do {
                    try fm.createDirectory(atPath:docDir, withIntermediateDirectories:true, attributes:nil)
                } catch {
                    NSLog("Error creating DB directory: \(docDir) on macOS")
                }
            }
        #endif
        let path = (docDir as NSString).appendingPathComponent(DB_NAME)
        #if DEBUG
            print(path)
        #endif
              
    
        //        NSLog("Database path: \(path)")
//        printLog(path)
        // Check if copy of DB is there in Documents directory
        if !(fm.fileExists(atPath:path)) {
            // The database does not exist, so copy to Documents directory
            guard let rp = Bundle.main.resourcePath else { return }
            let from = (rp as NSString).appendingPathComponent(DB_NAME)
            do {
                try fm.copyItem(atPath:from, toPath:path)
            } catch let error as NSError {
                NSLog("SQLiteDB - failed to copy writable version of DB!")
                NSLog("Error - \(error.localizedDescription)")
                return
            }
        }
        openDB(path:path)
    }
    
    private init(path:String) {
        super.init()
        openDB(path:path)
    }
    
    deinit {
        closeDB()
    }
    
    override open var description:String {
        return "SQLiteDB: \(String(describing: path))"
    }
    
    // MARK:- Class Methods
    class func openRO(path:String) -> SQLiteDB {
        let db = SQLiteDB(path:path)
        return db
    }
    
    // MARK:- Public Methods
    func dbDate(dt:Date) -> String {
        return fmt.string(from:dt)
    }
    
    func dbDateFromString(str:String, format:String="") -> Date? {
        let dtFormat = fmt.dateFormat
        if !format.isEmpty {
            fmt.dateFormat = format
        }
        let dt = fmt.date(from:str)
        if !format.isEmpty {
            fmt.dateFormat = dtFormat
        }
        return dt
    }
    
    // Execute SQL with parameters and return result code
   open func execute(_ sql:String, params:[Any]?=nil)->CInt {
        var result:CInt = 0
        queue.sync() {
            if let stmt = self.prepare(sql:sql, params:params) {
                result = self.execute(stmt:stmt, sql:sql)
            }
        }
        return result
    }
    
   open func execute(_ sql:String, parameters: NSMutableArray)->CInt {
        var p = [Any]()
        for param in parameters {
            p.append(param)
        }
        return execute(sql, params: p)
    }
    open func query(_ sql:String, parameters:NSMutableArray)->[SQLRow] {
        var p = [Any]()
        for param in parameters {
            p.append(param)
        }
        return query(sql, parameters: p)
    }
    // Run SQL query with parameters
    open func query(_ sql:String, parameters:[Any]?=nil)->[SQLRow] {
        var rows = [[String:Any]]()
        queue.sync() {
            if let stmt = self.prepare(sql:sql, params:parameters) {
                rows = self.query(stmt:stmt, sql:sql)
            }
        }
        var sqlRows = [SQLRow]()
        for row in rows {
            let r = SQLRow()
            r.data = row
            sqlRows.append(r)
        }
        return sqlRows
    }
    
    // Show alert with either supplied message or last error
    open func alert(msg:String) {
        DispatchQueue.main.async {
            #if os(iOS)
                let alert = UIAlertView(title: "SQLiteDB", message:msg, delegate: nil, cancelButtonTitle: "OK")
                alert.show()
            #else
                let alert = NSAlert()
                alert.addButton(withTitle:"OK")
                alert.messageText = "SQLiteDB"
                alert.informativeText = msg
                alert.alertStyle = NSAlertStyle.warning
                alert.runModal()
            #endif
        }
    }
    
    // Versioning
    func getDBVersion() -> Int {
        var version = 0
        let arr = query("PRAGMA user_version")
        if arr.count == 1 {
            version = arr[0].data["user_version"] as! Int
        }
        return version
    }
    
    // Sets the 'user_version' value, a user-defined version number for the database. This is useful for managing migrations.
    func setDBVersion(version:Int) {
        _ = execute("PRAGMA user_version=\(version)")
    }
    
    // MARK:- Private Methods
    private func openDB(path:String) {
        // Set up essentials
        queue = DispatchQueue(label:QUEUE_LABEL, attributes:[])
        // You need to set the locale in order for the 24-hour date format to work correctly on devices where 24-hour format is turned off
        fmt.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale?
        fmt.timeZone = NSTimeZone(forSecondsFromGMT:0) as TimeZone?
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // Open the DB
        let cpath = path.cString(using: String.Encoding.utf8)
        let error = sqlite3_open(cpath!, &db)
        if error != SQLITE_OK {
            // Open failed, close DB and fail
            NSLog("SQLiteDB - failed to open DB!")
            sqlite3_close(db)
            return
        }
        NSLog("SQLiteDB opened!")
    }
    
    private func closeDB() {
        if db != nil {
            // Get launch count value
            let ud = UserDefaults.standard
            var launchCount = ud.integer(forKey: "LaunchCount")
            launchCount -= 1
            NSLog("SQLiteDB - Launch count \(launchCount)")
            var clean = false
            if launchCount < 0 {
                clean = true
                launchCount = 500
            }
            ud.set(launchCount, forKey:"LaunchCount")
            ud.synchronize()
            // Do we clean DB?
            if !clean {
                sqlite3_close(db)
                return
            }
            // Clean DB
            NSLog("SQLiteDB - Optimize DB")
            let sql = "VACUUM; ANALYZE"
            if execute(sql) != SQLITE_OK {
                NSLog("SQLiteDB - Error cleaning DB")
            }
            sqlite3_close(db)
        }
    }
    
    // Private method which prepares the SQL
    private func prepare(sql:String, params:[Any]?) -> OpaquePointer? {
        var stmt:OpaquePointer? = nil
        let cSql = sql.cString(using: String.Encoding.utf8)
        // Prepare
        let result = sqlite3_prepare_v2(self.db, cSql!, -1, &stmt, nil)
        if result != SQLITE_OK {
            sqlite3_finalize(stmt)
            if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                let msg = "SQLiteDB - failed to prepare SQL: \(sql), Error: \(error)"
                NSLog(msg)
            }
            return nil
        }
        // Bind parameters, if any
        if params != nil {
            // Validate parametersapp
            let cntParams = sqlite3_bind_parameter_count(stmt)
            let cnt = params!.count
            if cntParams != cnt {
                let msg = "SQLiteDB - failed to bind parameters, counts did not match. SQL: \(sql), Parameters: \(String(describing: params))"
                NSLog(msg)
                return nil
            }
            var flag:CInt = 0
            // Text & BLOB values passed to a C-API do not work correctly if they are not marked as transient.
            for ndx in 1...cnt {
                //                NSLog("Binding: \(params![ndx-1]) at Index: \(ndx)")
                // Check for data types
                if let txt = params![ndx-1] as? String {
                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
                } else if let data = params![ndx-1] as? NSData {
                    flag = sqlite3_bind_blob(stmt, CInt(ndx), data.bytes, CInt(data.length), SQLITE_TRANSIENT)
                } else if let date = params![ndx-1] as? NSDate {
                    let txt = fmt.string(from: date as Date)
                    flag = sqlite3_bind_text(stmt, CInt(ndx), txt, -1, SQLITE_TRANSIENT)
                } else if let val = params![ndx-1] as? Double {
                    flag = sqlite3_bind_double(stmt, CInt(ndx), CDouble(val))
                } else if let val = params![ndx-1] as? Int {
                    flag = sqlite3_bind_int(stmt, CInt(ndx), CInt(val))
                } else {
                    flag = sqlite3_bind_null(stmt, CInt(ndx))
                }
                // Check for errors
                if flag != SQLITE_OK {
                    sqlite3_finalize(stmt)
                    if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                        let msg = "SQLiteDB - failed to bind for SQL: \(sql), Parameters: \(String(describing: params)), Index: \(ndx) Error: \(error)"
                        NSLog(msg)
                    }
                    return nil
                }
            }
        }
        return stmt
    }
    
    // Private method which handles the actual execution of an SQL statement
    private func execute(stmt:OpaquePointer, sql:String)->CInt {
        // Step
        var result = sqlite3_step(stmt)
        if result != SQLITE_OK && result != SQLITE_DONE {
            sqlite3_finalize(stmt)
            if let error = String(validatingUTF8:sqlite3_errmsg(self.db)) {
                let msg = "SQLiteDB - failed to execute SQL: \(sql), Error: \(error)"
                NSLog(msg)
            }
            return 0
        }
        // Is this an insert
        let upp = sql.uppercased()
        if upp.hasPrefix("INSERT ") {
            // Known limitations: http://www.sqlite.org/c3ref/last_insert_rowid.html
            let rid = sqlite3_last_insert_rowid(self.db)
            result = CInt(rid)
        } else if upp.hasPrefix("DELETE") || upp.hasPrefix("UPDATE") {
            var cnt = sqlite3_changes(self.db)
            if cnt == 0 {
                cnt += 1
            }
            result = CInt(cnt)
        } else {
            result = 1
        }
        // Finalize
        sqlite3_finalize(stmt)
        return result
    }
    
    
    // Private method which handles the actual execution of an SQL query
    private func query(stmt:OpaquePointer, sql:String)->[[String:Any]] {
        var rows = [[String:Any]]()
        var fetchColumnInfo = true
        var columnCount:CInt = 0
        var columnNames = [String]()
        var columnTypes = [CInt]()
        var result = sqlite3_step(stmt)
        while result == SQLITE_ROW {
            // Should we get column info?
            if fetchColumnInfo {
                columnCount = sqlite3_column_count(stmt)
                for index in 0..<columnCount {
                    // Get column name
                    let name = sqlite3_column_name(stmt, index)
                    columnNames.append(String(validatingUTF8:name!)!)
                    // Get column type
                    columnTypes.append(self.getColumnType(index:index, stmt:stmt))
                }
                fetchColumnInfo = false
            }
            // Get row data for each column
            var row = [String:Any]()
            for index in 0..<columnCount {
                let key = columnNames[Int(index)]
                let type = columnTypes[Int(index)]
                if let val = getColumnValue(index:index, type:type, stmt:stmt) {
                    //                        NSLog("Column type:\(type) with value:\(val)")
                    row[key] = val
                }
            }
            rows.append(row)
            // Next row
            result = sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        return rows
    }
    
    // Get column type
    private func getColumnType(index:CInt, stmt:OpaquePointer)->CInt {
        var type:CInt = 0
        // Column types - http://www.sqlite.org/datatype3.html (section 2.2 table column 1)
        let blobTypes = ["BINARY", "BLOB", "VARBINARY"]
        let charTypes = ["CHAR", "CHARACTER", "CLOB", "NATIONAL VARYING CHARACTER", "NATIVE CHARACTER", "NCHAR", "NVARCHAR", "TEXT", "VARCHAR", "VARIANT", "VARYING CHARACTER"]
        let dateTypes = ["DATE", "DATETIME", "TIME", "TIMESTAMP"]
        let intTypes  = ["BIGINT", "BIT", "BOOL", "BOOLEAN", "INT", "INT2", "INT8", "INTEGER", "MEDIUMINT", "SMALLINT", "TINYINT"]
        let nullTypes = ["NULL"]
        let realTypes = ["DECIMAL", "DOUBLE", "DOUBLE PRECISION", "FLOAT", "NUMERIC", "REAL"]
        // Determine type of column - http://www.sqlite.org/c3ref/c_blob.html
        let buf = sqlite3_column_decltype(stmt, index)
        //        NSLog("SQLiteDB - Got column type: \(buf)")
        if buf != nil {
            var tmp = String(validatingUTF8:buf!)!.uppercased()
            // Remove brackets
            let pos = tmp.positionOf(sub:"(")
            if pos > 0 {
                tmp = tmp.subString(start:0, length:pos)
            }
            // Remove unsigned?
            // Remove spaces
            // Is the data type in any of the pre-set values?
            //            NSLog("SQLiteDB - Cleaned up column type: \(tmp)")
            if intTypes.contains(tmp) {
                return SQLITE_INTEGER
            }
            if realTypes.contains(tmp) {
                return SQLITE_FLOAT
            }
            if charTypes.contains(tmp) {
                return SQLITE_TEXT
            }
            if blobTypes.contains(tmp) {
                return SQLITE_BLOB
            }
            if nullTypes.contains(tmp) {
                return SQLITE_NULL
            }
            if dateTypes.contains(tmp) {
                return SQLITE_DATE
            }
            return SQLITE_TEXT
        } else {
            // For expressions and sub-queries
            type = sqlite3_column_type(stmt, index)
        }
        return type
    }
    
    // Get column value
    private func getColumnValue(index:CInt, type:CInt, stmt:OpaquePointer)->Any? {
        // Integer
        if type == SQLITE_INTEGER {
            let val = sqlite3_column_int(stmt, index)
            return Int(val)
        }
        // Float
        if type == SQLITE_FLOAT {
            let val = sqlite3_column_double(stmt, index)
            return Double(val)
        }
        // Text - handled by default handler at end
        // Blob
        if type == SQLITE_BLOB {
            let data = sqlite3_column_blob(stmt, index)
            let size = sqlite3_column_bytes(stmt, index)
            let val = NSData(bytes:data, length:Int(size))
            return val
        }
        // Null
        if type == SQLITE_NULL {
            return nil
        }
        // Date
        if type == SQLITE_DATE {
            // Is this a text date
            if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
                let uptr = ptr.bindMemory(to:CChar.self, capacity:0)
                let txt = String(validatingUTF8:uptr)!
                let set = CharacterSet(charactersIn:"-:")
                if txt.rangeOfCharacter(from:set) != nil {
                    // Convert to time
                    var time:tm = tm(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0, tm_wday: 0, tm_yday: 0, tm_isdst: 0, tm_gmtoff: 0, tm_zone:nil)
                    strptime(txt, "%Y-%m-%d %H:%M:%S", &time)
                    time.tm_isdst = -1
                    let diff = NSTimeZone.local.secondsFromGMT()
                    let t = mktime(&time) + diff
                    let ti = TimeInterval(t)
                    let val = NSDate(timeIntervalSince1970:ti)
                    return val
                }
            }
            // If not a text date, then it's a time interval
            let val = sqlite3_column_double(stmt, index)
            let dt = NSDate(timeIntervalSince1970: val)
            return dt
        }
        // If nothing works, return a string representation
        if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
            let uptr = ptr.bindMemory(to:CChar.self, capacity:0)
            let txt = String(validatingUTF8:uptr)
            return txt
        }
        return nil
    }
    
    // MARK: - 事务处理
    /// 开启事务
    /*
     原因：在 SQLite 中，如果不主动开启事务，每个数据更新操作 (INSERT / UPDATE / DELETE) 都会默认开启一个事务，数据更新结束后自动提交事务
     */
    #if DEBUG
    var beginTime = CACurrentMediaTime()
    #endif
    open func beginTransaction(_ name : String = "TRANSACTION") {
     
        #if DEBUG
        beginTime = CACurrentMediaTime()
        print("sql执行开始")
        #endif
        
        sqlite3_exec(db, "BEGIN \(name);", nil, nil, nil)
    }
    
    /// 提交事务
    open func commitTransaction(_ name : String = "TRANSACTION") {
        sqlite3_exec(db, "COMMIT \(name);", nil, nil, nil)
        #if DEBUG
        let commitTime = CACurrentMediaTime()
        print(commitTime-beginTime)
        print("sql执行结束")
        #endif
    }
    
    /// 回滚事务
    open func rollbackTransaction(_ name : String = "TRANSACTION") {
        sqlite3_exec(db, "ROLLBACK \(name);", nil, nil, nil)
    }
    

    
    
}

