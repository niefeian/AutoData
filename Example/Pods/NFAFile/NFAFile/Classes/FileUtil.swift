//
//  FileUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import AVFoundation
import UIKit

public enum FileType {
      case log , video
}

open class FileUtil {
    
    
    public static let cachesPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
    
    /// 默认缩放到屏幕宽度
    open class func defaultImageScale(_ sourceImage : UIImage) -> UIImage {
        return imageScale(sourceImage, scaledToWidth: 960)
    }
    
    open class func imageScale(_ sourceImage : UIImage, scaledToWidth i_width : CGFloat) -> UIImage {
        var newWidth = i_width
        let oldWidth = sourceImage.size.width
        var scaleFactor : CGFloat! = 1
        if oldWidth > i_width {
            scaleFactor = i_width / oldWidth
        } else {
            newWidth = oldWidth
        }
        let newHeight = floor(sourceImage.size.height * scaleFactor)

        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        sourceImage.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    

    
    /// 彻底清除文件夹,异步:清理缓存用
    open class func cleanFolder(_ path: String = cachesPath, size : Double? = 0, complete:@escaping () -> ()) {
        var fs = size
        if fs == 0 {
            fs = folderSize(path)
        }
        
        let queue = DispatchQueue(label: "cleanQueue", attributes: [])
        
        queue.async { () -> Void in
            let manager = FileManager.default
            let chilerFiles = manager.subpaths(atPath: path)
            for fileName in chilerFiles! {
                let tmpPath = path as NSString
                let fileFullPathName = tmpPath.appendingPathComponent(fileName)
                if manager.fileExists(atPath: fileFullPathName) {
                    do {
                        try manager.removeItem(atPath: fileFullPathName)
                    } catch _ {
                    }
                }
                
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                complete()
            })
        }
    }
    
    /// 计算单个文件的大小
    open class func fileSize(_ path: String) -> Double {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let dict = try? fileManager.attributesOfItem(atPath: path)
            if let fileSize = dict![FileAttributeKey.size] as? Int{
                let d = Double(fileSize) / 1024.0 / 1024.0
                return d
            }
        }
        return 0.0
    }
    
    /// 计算整个文件夹的大小
    open class func folderSize(_ path: String = cachesPath) -> Double {
        var folderSize: Double = 0
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let chilerFiles = fileManager.subpaths(atPath: path)
            for fileName in chilerFiles! {
                let tmpPath = path as NSString
                let fileFullPathName = tmpPath.appendingPathComponent(fileName)
                folderSize += fileSize(fileFullPathName)
            }
            let factor =  pow(Double(10), 2)
            let ret = floor(folderSize * factor + 0.5) / factor;
            
            return ret
        }
        return 0
    }
    
    open class func getFilesPath(_ createPath : String, isDir : Bool = true) -> String? {
         let addlast =  isDir ? "/":""
         return getPath(file:cachesPath + "/" + createPath + addlast)
    }
    
    open class func getPath(_ fileType : FileType , isDir : Bool = true) -> String?{
        let addlast =  isDir ? "/":""
        switch fileType {
        case .log:
            return getPath(file:cachesPath + "/logs" + addlast)
        case .video:
            return getPath(file:cachesPath + "/video" + addlast)
        }
    }
    
    open class func getPath(file : String) -> String? {
        if fileExists(file) {
            return file
        }else{
            return nil
        }
    }
    
    
    open class func fileExists(_ filesPath : String) -> Bool{
         let fileMan = FileManager.default
         var isDir : ObjCBool = true
         if !fileMan.fileExists(atPath: filesPath, isDirectory: &isDir) {
             do {
                 try fileMan.createDirectory(atPath: filesPath, withIntermediateDirectories: true, attributes: nil)
             } catch {
                   #if DEBUG
                   print("create dir error")
                   #endif
                return false
             }
         }
        return  true
    }
    
    
}
