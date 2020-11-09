//
//  MD5Helper.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import UIKit

public func printLog<T>(_ message : T, file : String = #file, method : String = #function, line : Int = #line) {
    #if DEBUG
    print(file)
    print("\(line),\(method):\n\(message)")
    #endif
}


public func showTipsWindow(_ tips : String = "系统错误", delayTime : CGFloat = 4){

    let tipsView =  AppWindow().viewWithTag(999) ?? UIView()
    if tipsView.tag == 999 &&  tipsView.alpha != 0 {
        return
    }
    tipsView.backgroundColor = UIColor.initString( "000000", alpha: 0.8)
    tipsView.tag = 999
    AppWindow().addSubview(tipsView)
    tipsView.alpha = 0
    let label = tipsView.viewWithTag(888) as? UILabel ?? UILabel()
    if label.tag != 888
    {
        label.textAlignment  = .center
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        tipsView.addSubview(label)
    }

    label.text = tips
    label.sizeToFit()
    tipsView.frame = CGRect(x: 0, y: 0, width: label.width + 20, height: label.height + 20)
    label.frame = CGRect(x: 10, y: 10, width: label.width, height: label.height)
    tipsView.center = AppWindow().center

    Tools.setCornerRadius(tipsView, rate: 5)

    UIView.animate(withDuration: 0.3, animations: {
        tipsView.alpha = 1
    }) { (finished) in
        UIView.animate(withDuration: 0.3, delay: TimeInterval(delayTime), options: UIView.AnimationOptions.curveEaseOut, animations: {
          tipsView.alpha = 0
        }, completion: { (b) in
          tipsView.removeFromSuperview()
        })
    }
  }


public func getObject <T> (_ objc : AnyObject? , _ key : String = "" , _ autoComponents : Bool = true ) -> T?
{
    if key.count == 0
    {
        return objc as? T
    }
    else if key.contains("->") && autoComponents
    {
        let array = key.components(separatedBy: "->")
        var dic : [String:AnyObject]!
        if let maps = objc as? [String:AnyObject]{
            dic = maps
            for index in 0 ..< array.count
            {
                if index == array.count - 1
                {
                    return  getModel(map: dic as AnyObject, key: array[index])
                }
                else
                {
                    dic = getModel(map: dic as AnyObject, key: array[index])
                }
            }
        }
    }
    else
    {
        if let maps = objc as? [String:AnyObject]{
           return maps[key] as? T
        }
    }
    return nil
}

public func getModel <T> (map : AnyObject? , key : String) -> T?{
    if let maps = map as? [String:AnyObject]{
       return maps[key] as? T
    }
    return nil
}

public func getModel <T> (map : AnyObject?) -> T?{
    return map as? T
}


public let AppWidth: CGFloat = UIScreen.main.bounds.size.width
public let AppHeight: CGFloat = UIScreen.main.bounds.size.height
public var isIphoneX =  UIApplication.shared.statusBarFrame.height == 44
public let MainBounds: CGRect = UIScreen.main.bounds
public let StatusBarH : CGFloat = UIApplication.shared.statusBarFrame.height
public var ScreenHeightTabBar : CGFloat = UIApplication.shared.statusBarFrame.height == 44 ? 83 : 49
public var NavigationH  : CGFloat = StatusBarH == 44 ? 88: 64


public func pd6sW(_ pd : CGFloat) -> CGFloat{
    return pd * AppWidth / 375
}

public func pd6sH(_ pd : CGFloat) -> CGFloat{
    return pd * AppHeight / 568.0
}

public extension CGFloat {
    var valueBetweenZeroAndOne: CGFloat {
        return abs(self) > 1 ? 1 : abs(self)
    }

    var pd6sW : CGFloat {
        return self * AppWidth / 375
    }

    var pd6sH : CGFloat {
        return self * AppWidth / 375
    }

}


public extension Int {
    var pd6sW : CGFloat {
        return CGFloat(self) * AppWidth / 375
    }

    var pd6sH : CGFloat {
        return CGFloat(self) * AppWidth / 375
    }

}


public extension UIColor {
   class func initString( _ colorValue : String , alpha: CGFloat = 1) -> UIColor{
        var str = colorValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
          if str.hasPrefix("#") {
              str = str.replacingOccurrences(of: "#", with: "")
          }
          if str.count != 6 {
              return .white
          }
          let redStr = str.prefix(2)
          let greenStr = str.subString(start: 2, length: 2)
          let blueStr = str.subString(start: 4)
          var r:UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0
          Scanner(string: String(redStr)).scanHexInt64(&r)
          Scanner(string: greenStr).scanHexInt64(&g)
          Scanner(string: blueStr).scanHexInt64(&b)
          return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
}


import CommonCrypto
public extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: self)
    }
    
    var decodeBase64 : String{
        return String(data: Data(base64Encoded: self, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) ?? Data(), encoding: .utf8) ?? ""
    }
    
    var base64EncodedString : String {
        let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true)
        // 将NSData进行Base64编码
        return utf8EncodeData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: UInt(0))) ?? ""
    }
       
    var urlEncoded : String{
        return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, self as NSString, nil,
                                                       "!*'();:@&=+$,/?%#[]" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue)) as String
    }
    
    var urlDecoded : String {
       let res:NSString = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, self as NSString, "" as CFString?, CFStringConvertNSStringEncodingToEncoding(String.Encoding.utf8.rawValue))
       return res as String
   }
    
    var map : [String:Any]?{
        if let data = self.data(using:String.Encoding.utf8){
            if let dic = try? JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers)as? [String: Any] {
                return dic
            }
        }
       return nil
    }
    
    
    func stringToDic() -> [String:Any]? {
        return self.map
    }
    
    var array : Array<Any>?{
        if let data = self.data(using:String.Encoding.utf8){
        if let array = try? JSONSerialization.jsonObject(with: data,options: JSONSerialization.ReadingOptions.mutableContainers)as? Array<Any> {
               return array
           }
        }
        return nil
    }
    
    var html : NSAttributedString?{
        do{
        return try NSAttributedString(data: self.data(using: String.Encoding.unicode, allowLossyConversion: true)!, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        }catch _ {

        }
       return nil
    }
    
    var md5 : String{
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen);

        CC_MD5(str!, strLen, result);

        let hash = NSMutableString();
        for i in 0 ..< digestLen {
           hash.appendFormat("%02x", result[i]);
        }
        result.deinitialize(count: 0);

        return String(format: hash as String).lowercased()
    }
  
    
    func substringToIndex(_ to : Int) -> String {
        
        var temp : NSString = self as NSString
        let length = temp.length
        if to > length {
            return self
        }
        temp = temp.substring(to: to - 1) as NSString
        return temp as String
    }
    
    func subString(start:Int, length:Int = -1)->String {
        if start < 0
        {
            return self
        }
        
        var len = length
        if len == -1 {
            len = count - start
        }
        let st = index(startIndex, offsetBy:start)
        let en = index(st, offsetBy:len)
        let range = st ..< en
        return substring(with:range)
    }
    
    func floatValue() -> CGFloat {
         //返回的是个可选值，不一定有值，也可能是nill
         let double = Double(self)
         //返回的double是个可选值，所以需要给个默认值或者用!强制解包
         return CGFloat(double ?? 0)
    }
    
    func positionOf(sub:String)->Int {
       var pos = -1
       if let range = range(of:sub) {
           if !range.isEmpty {
               pos = distance(from:startIndex, to:range.lowerBound)
           }
       }
       return pos
    }
    
   /**
    将当前字符串拼接到cache目录后面
    */
   func cacheDir() -> String{
       let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
       return path.appendingPathComponent((self as NSString).lastPathComponent)
   }
   /**
    将当前字符串拼接到doc目录后面
    */
   func docDir() -> String
   {
       let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!  as NSString
       return path.appendingPathComponent((self as NSString).lastPathComponent)
   }
   /**
    将当前字符串拼接到tmp目录后面
    */
   func tmpDir() -> String
   {
       let path = NSTemporaryDirectory() as NSString
       return path.appendingPathComponent((self as NSString).lastPathComponent)
   }
    

   
   //获取拼音首字母（大写字母）
   func findFirstLetterFromString(aString: String) -> String {
       //转变成可变字符串
       let mutableString = NSMutableString.init(string: aString)

       //将中文转换成带声调的拼音
       CFStringTransform(mutableString as CFMutableString, nil,      kCFStringTransformToLatin, false)

       //去掉声调
       let pinyinString = mutableString.folding(options:          String.CompareOptions.diacriticInsensitive, locale:   NSLocale.current)

       //将拼音首字母换成大写
       let strPinYin = polyphoneStringHandle(nameString: aString,    pinyinString: pinyinString).uppercased()

       //截取大写首字母
       let firstString = strPinYin.substring(to:     strPinYin.index(strPinYin.startIndex, offsetBy: 1))

       //判断首字母是否为大写
       let regexA = "^[A-Z]$"
       let predA = NSPredicate.init(format: "SELF MATCHES %@", regexA)
       return predA.evaluate(with: firstString) ? firstString : "#"
   }

   //多音字处理，根据需要添自行加
   func polyphoneStringHandle(nameString: String, pinyinString: String) -> String {
       if nameString.hasPrefix("长") {return "chang"}
       if nameString.hasPrefix("沈") {return "shen"}
       if nameString.hasPrefix("厦") {return "xia"}
       if nameString.hasPrefix("地") {return "di"}
       if nameString.hasPrefix("重") {return "chong"}
       return pinyinString
   }
   
   
   func getAttrString( lineSpacing:CGFloat = 5 , array : [(String,UIColor,CGFloat)] = [(String,UIColor,CGFloat)](), arrayFont : [(String,UIColor,UIFont)]  = [(String,UIColor,UIFont)](), arrays : [(String,[NSAttributedString.Key : Any])] = [(String,[NSAttributedString.Key : Any])]()) -> NSMutableAttributedString {
       
       let paraph = NSMutableParagraphStyle()
       paraph.lineSpacing = lineSpacing

       let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
       let attrString = NSMutableAttributedString(string: self , attributes: attributes)
       
       for arr in array
       {
          let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: arr.2),.foregroundColor: arr.1]
          let i  = self.positionOf(sub: arr.0)
          if  i >= 0  && i < self.count
          {
              attrString.addAttributes(attr, range:NSRange(location: self.positionOf(sub: arr.0), length: arr.0.count))
          }
       }
       
       for arr in arrayFont
       {
           let attr: [NSAttributedString.Key : Any] = [.font: arr.2,.foregroundColor: arr.1]
           let i  = self.positionOf(sub: arr.0)
           if  i >= 0  && i < self.count
           {
               attrString.addAttributes(attr, range:NSRange(location: self.positionOf(sub: arr.0), length: arr.0.count))
           }
       }
       for arr in arrays
       {
           let i  = self.positionOf(sub: arr.0)
           if  i >= 0  && i < self.count
           {
               attrString.addAttributes(arr.1, range:NSRange(location:i, length: arr.0.count))
           }
       }
       return attrString
   }
    
    
      
    func pregReplace(pattern: String, with: String,
                     options: NSRegularExpression.Options = []) -> String {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        return regex?.stringByReplacingMatches(in: self, options: [],
                                              range: NSMakeRange(0, self.count),
                                              withTemplate: with) ?? self
    }
}

public extension Dictionary {
     
    mutating func addAll(_ dic : Dictionary) {
        for (k , v) in dic {
            self[k] = v
        }
    }
    
    func dicValueString() ->String?{
        if let data = try? JSONSerialization.data(withJSONObject: self,options: []){
            let str = String(data: data,encoding:String.Encoding.utf8)
            return str
        }
        return nil
    }
    
}

public extension Array {
    
    func arrayToString() ->String?{
           if let data = try? JSONSerialization.data(withJSONObject: self,options: []){
               let str = String(data: data,encoding:String.Encoding.utf8)
               return str
           }
           return nil
       }
}

/// 对UIView的扩展
public extension UIView {
    /// 宽度
    var width: CGFloat {
        return self.frame.size.width
    }
    ///高度
    var height: CGFloat {
        return self.frame.size.height
    }
    
    func setCornerRadius(_ rate : CGFloat = 5) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = rate
    }
}


public extension UITableView {
    func autoRowHeight(){
        self.estimatedRowHeight = 100.0
        self.rowHeight = UITableView.automaticDimension
    }
    
    func scrollToIndexPath(_ indexPath : IndexPath , _ offsetY : CGFloat = 0 )
    {
           //获取当前cell在tableview中的位置
        let rectintableview = rectForRow(at: indexPath)
        let contentoffset = CGPoint(x: contentOffset.x, y: contentOffset.y)
        setContentOffset(CGPoint(x: contentoffset.x, y: rectintableview.origin.y + offsetY), animated: true)
        
    }
    
}

public extension UITableViewCell {
    func setRowSelectDisable(){
        self.accessoryType = UITableViewCell.AccessoryType.none
        self.selectionStyle = UITableViewCell.SelectionStyle.none
    }
}

public extension UILabel {
    
    func setFont(_ font : CGFloat){
       self.font = UIFont.systemFont(ofSize: pd6sW(font))
    }

    func setFont(_ font : CGFloat , weight : CGFloat){
        if #available(iOS 8.2, *) {
            self.font = UIFont.systemFont(ofSize: pd6sW(font), weight: UIFont.Weight.init(pd6sW(weight)))
        } else {
            // Fallback on earlier versions
        }
    }


    func setLable(text : String ,lineSpacing:CGFloat = 10 ) {
       let paraph = NSMutableParagraphStyle()
       paraph.lineSpacing = lineSpacing
       let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
       self.attributedText = NSAttributedString(string: text, attributes: attributes)
    }

    func setLineSpacing(_ lineSpacing : CGFloat = 5 ) {
       self.setLable(text: self.text ?? "", lineSpacing: lineSpacing)
    }

    func setAttrString2(string : String , lineSpacing:CGFloat = 5 , array : [([String],UIColor,CGFloat)]) {
        var arrays = [(String,UIColor,CGFloat)]()
        for arr in array {
            for str in arr.0
            {
                arrays.append((str, arr.1, arr.2))
            }
          }
         self.attributedText = string.getAttrString(lineSpacing: lineSpacing, array: arrays, arrayFont: [], arrays: [])
    }

    func setAttrString(string : String , lineSpacing:CGFloat = 5 , array : [(String,UIColor,CGFloat)] , offSize : Int = 0) {
          let paraph = NSMutableParagraphStyle()
          paraph.lineSpacing = lineSpacing
          let attributes = [NSAttributedString.Key.paragraphStyle: paraph]
       let attrString = NSMutableAttributedString(string: string , attributes: attributes)

       for arr in array {
           let attr: [NSAttributedString.Key : Any] = [.font: UIFont.systemFont(ofSize: arr.2),.foregroundColor: arr.1]
           let i  = string.positionOf(sub: arr.0) + offSize
           if  i >= 0  && i < string.count {
               attrString.addAttributes(attr, range:NSRange(location: string.positionOf(sub: arr.0) + offSize, length: arr.0.count))
           }
       }
       self.attributedText = attrString
    }
    

    
    func setAttrStringBy( string : String , lineSpacing:CGFloat = 5 , array : [(String,UIColor,CGFloat)] = [(String,UIColor,CGFloat)](), arrayFont : [(String,UIColor,UIFont)]  = [(String,UIColor,UIFont)](), arrays : [(String,[NSAttributedString.Key : Any])] = [(String,[NSAttributedString.Key : Any])]()) {
        self.attributedText = string.getAttrString(lineSpacing: lineSpacing, array: array, arrayFont: arrayFont, arrays: arrays)
    }

    func setAttrStrings(string : String , lineSpacing:CGFloat = 5 , array : [(String,[NSAttributedString.Key : Any])]) {
        self.attributedText = string.getAttrString(lineSpacing: lineSpacing, array: [], arrayFont: [], arrays: array)
    }
}

public extension UIFont {
   
    class func getStrikethroughFont(_ size : CGFloat , foregroundColor : UIColor , strikethroughColor : UIColor) -> [NSAttributedString.Key : Any]{
        return [.font: UIFont.systemFont(ofSize: size),.foregroundColor: foregroundColor, .strikethroughStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: strikethroughColor]
    }
    
    class func getUnderlineStyleFont(_ size : CGFloat , foregroundColor : UIColor , strikethroughColor : UIColor , linkUrl : String) -> [NSAttributedString.Key : Any]{
        if linkUrl.count > 0 {
              return [.font: UIFont.systemFont(ofSize: size),.foregroundColor: foregroundColor, .underlineStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: strikethroughColor,.link : linkUrl]
        }else{
              return [.font: UIFont.systemFont(ofSize: size),.foregroundColor: foregroundColor, .underlineStyle: NSUnderlineStyle.single.rawValue, .strikethroughColor: strikethroughColor]
        }
    }
    
    class func getObliqueFont(_ size : CGFloat) -> UIFont{
        return  UIFont.init(name: "Helvetica-Oblique", size: size) ?? UIFont.systemFont(ofSize: size)
      }
    
    class func getBoldObliqueFont(_ size : CGFloat) -> UIFont{
        return  UIFont.init(name: "Helvetica-BoldOblique", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}

public extension NSDictionary {

    func string(forKey key : String, _ defaultValue : String = "") -> String{
        return object(forKey: key) as? String ?? defaultValue
    }
    
    func bool(forKey key : String, _ defaultValue : Bool = false) -> Bool{
           return object(forKey: key) as? Bool ?? defaultValue
    }

    func integer(forKey key : String, _ defaultValue : Int = 0) -> Int{
        if  let integer = object(forKey: key) as? Int {
            return integer
        }else if  let string = object(forKey: key) as? String {
            return Int(string) ?? defaultValue
        }
        return  defaultValue
    }

    func doubleValue(forKey key : String, _ defaultValue : Double = 0.0) -> Double{
        if  let integer = object(forKey: key) as? Double {
            return integer
        }else if  let string = object(forKey: key) as? NSString {
            return string.doubleValue
        }
        return  defaultValue
    }
}

 public extension Int {
   
    var cn1: String {
        get {
            if self == 0 {
                return "零"
            }
            let zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            let units = ["", "十", "百", "千", "万", "十", "百", "千", "亿", "十","百","千"]
            var cn = ""
            var currentNum = 0
            var beforeNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                if index == 0{
                    if currentNum != 0 {
                        cn = zhNumbers[currentNum]
                        continue
                    }
                } else {
                    beforeNum = self/Int(pow(10.0,Double(index-1)))%10
                }
                if [1,2,3,5,6,7,9,10,11].contains(index) {
                    if currentNum == 1 && [1,5,9].contains(index) && index == intLength { // 处理一开头的含十单位
                        cn = units[index] + cn
                    } else if currentNum != 0 {
                        cn = zhNumbers[currentNum] + units[index] + cn
                    } else if beforeNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                    continue
                }
                if [4,8,12].contains(index) {
                    cn = units[index] + cn
                    if (beforeNum != 0 && currentNum == 0) || currentNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                }
            }
            return cn
        }
    }
    
    var cn2: String {
        get {
            if self == 0 {
                return "零"
            }
            let zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            var cn = ""
            var currentNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                cn = zhNumbers[currentNum] + cn
            }
            return cn
        }
    }
}

public extension UITextField{
    
    private static var getTextFieldTag = "textFieldTag"
    //通过关联对象给UITextField增加标签
    @objc var textFieldTag : String? {
        get {return objc_getAssociatedObject(self, &UITextField.getTextFieldTag) as? String }
        set { objc_setAssociatedObject(self, &UITextField.getTextFieldTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    
    func setAttributedPlaceholderIColor(_ color : UIColor) {
        if let string = self.placeholder {
            self.attributedPlaceholder =  NSAttributedString.init(string:string, attributes: [
                NSAttributedString.Key.foregroundColor:color])
        }
    }
       
}


extension NSObject {
    /*方法混淆*/
    static func getswizzleMethod(_ cls: AnyClass?, _ originSelector: Selector, _ swizzleSelector: Selector)  {
        let originMethod = class_getInstanceMethod(cls, originSelector)
        let swizzleMethod = class_getInstanceMethod(cls, swizzleSelector)
        guard let swMethod = swizzleMethod, let oMethod = originMethod else { return }
        let didAddSuccess: Bool = class_addMethod(cls, originSelector, method_getImplementation(swMethod), method_getTypeEncoding(swMethod))
        if didAddSuccess {
            class_replaceMethod(cls, swizzleSelector, method_getImplementation(oMethod), method_getTypeEncoding(oMethod))
        } else {
            method_exchangeImplementations(oMethod, swMethod)
        }
    }
}

// 修复图片旋转
extension UIImage {
    //系统拍完照 会默认旋转90 这里做还原操作
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        var transform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi / 2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi / 2)
            break
        default:
            break
        }
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        ctx?.concatenate(transform)
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.height), height: CGFloat(size.width)))
            break
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(size.width), height: CGFloat(size.height)))
            break
        }
        let cgimg: CGImage = (ctx?.makeImage())!
        let img = UIImage(cgImage: cgimg)
        return img
    }
    
    func fixOrientationX()  -> UIImage  {
        let flipImage = UIImage(cgImage: self.cgImage!, scale: 1.0, orientation: .leftMirrored)
        return flipImage
    }
}

