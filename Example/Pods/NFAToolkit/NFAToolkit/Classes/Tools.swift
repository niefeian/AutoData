//
//  Tools.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import UIKit


open class Tools {
    
    /// 清除角标
    open class func cleanMyAppBadge() {
        let app = UIApplication.shared
        let num = app.applicationIconBadgeNumber
        if num != 0 {
            app.cancelAllLocalNotifications()
            app.applicationIconBadgeNumber = 0
        }
    }
    
    open class func getUUID() -> String{
        let uc = CFUUIDCreate(nil)
        let uuid  = CFUUIDCreateString(nil, uc)
        return uuid! as String
    }
    
    /// 打开新的页面
    open class func openView(_ baseView : UIViewController, storyboard : String, identifier : String) {
        func fun(_ view : UIViewController){
        }
        openView(baseView, storyboard: storyboard, identifier: identifier, fun: fun)
    }
    
    open class func openView(_ baseView : UIViewController, storyboard : String, identifier : String, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        baseView.present(vw, animated: true, completion: nil)
        // callback，允许上一页面做特殊处理，比如传参等
        fun(vw as UIViewController)
    }
    
    /// 转场用场景切换
    open class func pushView(_ baseView : UIViewController, storyboard : String, identifier : String) {
        func fun(_ view : UIViewController){
        }
        self.pushView(baseView, storyboard: storyboard, identifier: identifier, fun: fun)
    }
    
    open class func pushTabView(_ baseView : UIViewController, storyboard : String, identifier : String, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        baseView.navigationController?.pushViewController(vw, animated: true)
        fun(vw as UIViewController)
    }
    
    open class func pushView(_ baseView : UIViewController, storyboard : String, identifier : String, hideBottom : Bool = true, animator : Bool = true, removeSelf : Bool = false, fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        let navUI = vw as! UINavigationController
        let child = navUI.children[0]
        let childView = child as UIViewController
        if hideBottom {
            childView.hidesBottomBarWhenPushed = true
        }
        // 禁止重复打开
        var views = baseView.navigationController?.viewControllers
       
        if views?.count ?? 0 > 0 {
            if childView.classForCoder == views![views!.count - 1].classForCoder {
                return
            }
        }
        
        if removeSelf && views != nil {
            views!.removeLast()
            views!.append(childView)
            baseView.navigationController?.setViewControllers(views!, animated: true)
        } else {
            baseView.navigationController?.pushViewController(childView, animated: animator)
        }
        fun(childView)
    }
    
    open class func pushView(_ baseView : UIViewController, toView : UIViewController , hideBottom : Bool = true, animator : Bool = true , repeatSelf : Bool = true , removeSelf : Bool = false, fun:(UIViewController) -> Void) {
           let childView = toView
           if hideBottom {
               childView.hidesBottomBarWhenPushed = true
           }
           // 禁止重复打开
           var views = baseView.navigationController?.viewControllers
           if views?.count ?? 0 > 0 && !repeatSelf {
               if childView.classForCoder == views![views!.count - 1].classForCoder {
                   return
               }
           }
           
            fun(childView)
           if removeSelf && views != nil {
               views!.removeLast()
               views!.append(childView)
               baseView.navigationController?.setViewControllers(views!, animated: true)
           } else {
               baseView.navigationController?.pushViewController(childView, animated: animator)
           }
           
    }
    
    /// 以根节点的方式打开
    open class func rootView(_ window : UIWindow, storyboard : String, identify : String) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        let vw = bord.instantiateViewController(withIdentifier: identify)
        window.rootViewController = vw;
        window.makeKeyAndVisible()
    }
    
    /// 转场回退
    open class func popView(_ baseView : UIViewController) {
        baseView.navigationController?.popViewController(animated: true)
    }
    
    /// 回退到指定的界面
    open class func popToView(_ baseView : UIViewController, toViewClass : AnyClass) -> Bool{
        if let views = baseView.navigationController?.viewControllers{
            var toView : UIViewController?
            for view in views {
                let v = view as UIViewController
                if v.classForCoder == toViewClass {
                    toView = v
                    break
                }
            }
            if toView != nil {
                baseView.navigationController?.popToViewController(toView!, animated: true)
                return true
            }
        }
        return false
    }
    
    /// 构建标题：当文字超长时，采用titleView进行构建，否则下一个试图的title会偏移
    open class func addTitleView(view : UIView, navigationItem : UINavigationItem, title : String? , textColor : UIColor = UIColor.black) {
        let navigationH  : CGFloat = UIApplication.shared.statusBarFrame.height == 44 ? 88: 64
        let titleView = UILabel(frame: CGRect(x: navigationH - 40, y: 0, width: UIScreen.main.bounds.size.width - 100, height: 30))
        navigationItem.titleView = titleView
        DispatchQueue.main.async {
            let width = UIScreen.main.bounds.size.width  - 100
            let centerView = UILabel()
            centerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y:  navigationH - 40, width: width, height: 30)
            centerView.frame = (view.window?.convert(centerView.frame, to: navigationItem.titleView))!
            centerView.text = title
            centerView.textAlignment = .center
            centerView.font = UIFont.boldSystemFont(ofSize: 17)
            centerView.textColor = textColor
            navigationItem.titleView?.addSubview(centerView)
        }
    }
    
    /// 执行几次的动画
    open class func animationSomeTimes(_ time : TimeInterval = 0.2, count : Int = 1 , doing : @escaping CBWithParam , doend : @escaping CBWithParam, finish : @escaping CB) {
        if count < 1 {
            return
        }
        var c = count
        UIView.animate(withDuration: time, animations: {
            c = count - 1
            doing(c as AnyObject?)
        }, completion: { (Bool) in
            if c > 0 {
                UIView.animate(withDuration: time, animations: {
                    doend(c as AnyObject?)
                }, completion: { (Bool) in
                    self.animationSomeTimes(time, count: c, doing: doing, doend: doend, finish: finish)
                })
            } else {
                finish()
            }
        })  
    }
    
    
    
    open class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    /// 非空校验
    open class func validateEmpty(_ baseView : UIViewController, msgs : [String], textFields : [UITextField]) -> Bool {
        let count = msgs.count
        for i in 0 ..< count {
            if (textFields[i].text == nil || textFields[i].text == "") {
                return false
            }
        }
        return true
    }
    
    /// 包含
    open class func contains(_ arrays : [AnyObject], key : String) -> Bool {
        let contain = arrays.contains { (element) -> Bool in
            let ele = element as! String
            if ele == key {
                return true
            }
            return false
        }
        return contain
    }
    
    /// 是否为空
    open class func isEmpty(_ obj : AnyObject?) -> Bool {
        if obj == nil {
            return true
        }
        if obj is String {
            return obj as! String == ""
        }
        if obj is NSArray {
            return (obj as! NSArray).count == 0
        }
        if obj is NSDictionary {
            return (obj as! NSDictionary).count == 0
        }
        
        return false
    }
    /// 主要用于tableViewCell之类的动画显示。从底部慢慢滑上来出现
    open class func displayViewAnimationMoveIn(_ view: UIView, offsetY: CGFloat, duration: TimeInterval) {
        
        view.transform = CGAffineTransform(translationX: 0, y: offsetY)
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            view.transform = CGAffineTransform.identity
        })
    }
    
    /// 主要用于tableViewCell之类的动画显示。从透明到非透明（淡入）
    open class func displayViewAnimationFadeIn(_ view: UIView, defaultAlpha : CGFloat = 0, duration: TimeInterval) {
        view.alpha = defaultAlpha
        UIView.animate(withDuration: duration, animations: { () -> Void in
            view.alpha = 1
        })
    }
    
    /// 隐藏、显示nav标题
    open class func tapToggleNavBarHidden(_ navigationController : UINavigationController) {
        navigationController.setNavigationBarHidden(!navigationController.isNavigationBarHidden, animated: true)
    }
    
    /// 清除tab页签上的横线
    open class func removeTabBarTopLine(_ tabBar : UITabBar) {
        
        // 去掉原有的tab栏上的顶部横向
        let rect = CGRect(x: 0, y: 0, width: tabBar.frame.size.width, height: tabBar.frame.size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.clear.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        tabBar.backgroundImage = img
        tabBar.shadowImage = img
    }
    
    /// 圆角
    open class func setCornerRadius(_ view : UIView, rate : CGFloat = 5) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = rate
    }
    
    /// 圆形图标
    open class func setCircleCornerRadius(_ view : UIView) {
        view.layer.masksToBounds = true
        let r = view.frame.size.width / 2
        view.layer.cornerRadius = r
    }
    
    
    /// 随机数 : 调用：radomInRange(1..<100)
    open class func radomInRange(_ range : Range<Int>) -> Int {
        let count = UInt32(range.upperBound - range.lowerBound)
        return Int(arc4random_uniform(count)) + range.lowerBound
    }
    
    /// 旋转角度。传入角度，正数为顺时针，负数为逆时针，如逆时针旋转25度：transformRotation(25)
    open class func transformRotation(_ angle : Double) -> CGAffineTransform {
        let r : Double = angle / 180
        return CGAffineTransform(rotationAngle: CGFloat(-1 * Double.pi * r))
    }
    
    /// 构建数组对应的json字符串
    open class func arraysToJson(_ arrs : NSArray, key : String) -> String? {
        let d = NSMutableArray()
        for data in arrs {
            let dic = NSMutableDictionary()
            dic.setValue((data as! String), forKey: key)
            d.add(dic)
        }
        var json : String?
        do {
            let data = try JSONSerialization.data(withJSONObject: d, options: JSONSerialization.WritingOptions.prettyPrinted)
            let strJson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            json = strJson! as String
        }catch let e {
            print(e)
            return nil
        }
        
        guard let j = json else {
            return nil
        }
        json = j.replacingOccurrences(of: "\n", with: "")
        return json
    }

    // 使用16进制颜色
    open class func colorConversion(colorValue: String, alpha: CGFloat = 1) -> UIColor {
        var str = colorValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        if str.hasPrefix("#") {
            str = str.replacingOccurrences(of: "#", with: "")
        }
        if str.count != 6 {
            return .white
        }
        let redStr = str.subString(start: 0, length: 2)
        let greenStr = str.subString(start: 2, length: 2)
        let blueStr = str.subString(start: 4, length: 2)
        var r:UInt64 = 0, g:UInt64 = 0, b:UInt64 = 0
        Scanner(string: redStr).scanHexInt64(&r)
        Scanner(string: greenStr).scanHexInt64(&g)
        Scanner(string: blueStr).scanHexInt64(&b)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: alpha)
    }
    
    //设置圆角并描边
   open class func masksToBounds(cornerView:UIView,cornerRadius:CGFloat = 0 , borderWidth:CGFloat = 0 , borderColor : UIColor) {
        cornerView.layer.cornerRadius = cornerRadius
        cornerView.layer.borderWidth = borderWidth
        cornerView.layer.borderColor = borderColor.cgColor
    }
    
    
    /// 部分圆角
    ///
    /// - Parameters:
    ///   - corners: 需要实现为圆角的角，可传入多个
    ///   - radii: 圆角半径
    //    let corners: UIRectCorner = [.bottomLeft,.bottomRight]
    open class  func serCorner( _ view : UIView , byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
           let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
           let maskLayer = CAShapeLayer()
           maskLayer.frame = view.bounds
           maskLayer.path = maskPath.cgPath
           view.layer.mask = maskLayer
    }
    
    
    //设置阴影背景
    open class func setShadow(view:UIView,width:CGFloat,bColor:UIColor,
                   sColor:UIColor,offset:CGSize,opacity:Float,radius:CGFloat) {
        //设置视图边框宽度
        view.layer.borderWidth = width
        //设置边框颜色
        view.layer.borderColor = bColor.cgColor
        //设置边框圆角
        view.layer.cornerRadius = radius
        //设置阴影颜色
        view.layer.shadowColor = sColor.cgColor
        //设置透明度
        view.layer.shadowOpacity = opacity
        //设置阴影半径
        view.layer.shadowRadius = radius
        //设置阴影偏移量
        view.layer.shadowOffset = offset
    }
    
   open class func getViewController(_ storyboard : String,_ identifier : String)  -> UIViewController? {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        return bord.instantiateViewController(withIdentifier: identifier)
    }
    
    open class func pushIndexView(_ baseView : UIViewController, storyboard : String, identifier : String, hideBottom : Bool = true, animator : Bool = true, index : Int = 0 , isNoContains : Bool = true  , fun:(UIViewController) -> Void) {
            let bord = UIStoryboard(name: storyboard, bundle: nil)
            let vw = bord.instantiateViewController(withIdentifier: identifier)
            let navUI = vw as! UINavigationController
            let child = navUI.children[0]
            let childView = child as UIViewController
            if hideBottom {
                childView.hidesBottomBarWhenPushed = true
            }
           if var views = baseView.navigationController?.viewControllers {
               while !( index > views.count || index == 0 || views.count < 2)
               {
                   views.removeLast()
               }
                 
               views.append(childView)
               baseView.navigationController?.setViewControllers(views, animated: true)
           }
           fun(childView)
    }

    open class func addTitleView(baseView : UIViewController, title : String?) -> UILabel{

          let navigationH : CGFloat = UIApplication.shared.statusBarFrame.height == 44 ? 88 : 64
          let titleView = UILabel(frame: CGRect(x: 0 , y: 0 , width: UIScreen.main.bounds.size.width - 100, height: navigationH))
           let centerView = UILabel()
           baseView.navigationItem.titleView = titleView
           DispatchQueue.main.async {
               let width = UIScreen.main.bounds.size.width  - 100
               
               centerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y: navigationH - 44, width: width, height: 44)
               if baseView.navigationItem.titleView != nil
               {
                   centerView.frame = baseView.view.window?.convert(centerView.frame, to: baseView.navigationItem.titleView) ?? CGRect.zero
               }

               centerView.text = title
               centerView.textAlignment = .center
               centerView.font = UIFont.boldSystemFont(ofSize: 17)
               centerView.textColor = UIColor.black
               baseView.navigationItem.titleView?.addSubview(centerView)
           }

           return centerView
    }

    open  class func addTitleView(view : UIView, navigationItem : UINavigationItem, title : String?) {

        let navigationH : CGFloat = UIApplication.shared.statusBarFrame.height == 44 ? 88 : 64
        let titleView = UILabel(frame: CGRect(x: 0 , y: 0 , width: UIScreen.main.bounds.size.width - 100, height: navigationH))
          navigationItem.titleView = titleView
          DispatchQueue.main.async {
              let width = UIScreen.main.bounds.size.width  - 100
              let centerView = UILabel()
              centerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - width) / 2, y: navigationH - 44, width: width, height: 44)
              centerView.frame = (view.window?.convert(centerView.frame, to: navigationItem.titleView))!
              centerView.text = title
              centerView.textAlignment = .center
              centerView.font = UIFont.boldSystemFont(ofSize: 17)
              centerView.textColor = UIColor.black
              navigationItem.titleView?.addSubview(centerView)
          }
    }

    
    open class func pushView(_ baseView : UIViewController, storyboard : String, identifier : String, hideBottom : Bool = true, animator : Bool = true, removeSelf : Bool = false , isNoContains : Bool = true  , fun:(UIViewController) -> Void) {
        let bord = UIStoryboard(name: storyboard, bundle: nil)
        let vw = bord.instantiateViewController(withIdentifier: identifier)
        let navUI = vw as! UINavigationController
        let child = navUI.children[0]
        let childView = child as UIViewController
        if hideBottom {
            childView.hidesBottomBarWhenPushed = true
        }
        // 禁止重复打开
        var views = baseView.navigationController?.viewControllers
        if views?.count ?? 0 > 0  && isNoContains{
            if childView.classForCoder == views![views!.count - 1].classForCoder {
                return
            }
        }
        
        if removeSelf && views != nil {
            views!.removeLast()
            views!.append(childView)
            baseView.navigationController?.setViewControllers(views!, animated: true)
        } else {
            baseView.navigationController?.pushViewController(childView, animated: animator)
        }
        fun(childView)
    }
    
    /// 表格中section区间内从第n行开始增加rows行
       open class func insertRows(count : Int, at tableView : UITableView, from : Int, where sectionEqual : Int) {
           var indexPaths = [IndexPath]()
           for i in 0..<count {
               indexPaths.append(IndexPath(row: from + i, section: sectionEqual))
           }
           tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
       }
       
      open class func removeRows(count : Int, at tableView : UITableView, from : Int, where sectionEqual : Int){
           var indexPaths = [IndexPath]()
           for i in 0..<count {
               indexPaths.append(IndexPath(row: from + i, section: sectionEqual))
           }
           tableView.deleteRows(at: indexPaths, with: .none)
       }
    
    
    open class func reloadRows(oldCount : Int , newCount : Int , at tableView : UITableView , where sectionEqual : Int) {
        let add = newCount > oldCount
        let maxCount = add ? newCount : oldCount
        let minCount = !add ? newCount : oldCount
        var indexPaths = [IndexPath]()
        
        for i in 0..<maxCount-minCount {
            indexPaths.append(IndexPath(row: minCount + i, section: sectionEqual))
        }
        
        if add {
            tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.none)
        }else{
            tableView.deleteRows(at: indexPaths, with: .none)
        }
    }
    
    open class func updateRows(oldCount : Int , newCount : Int , at tableView : UITableView , where sectionEqual : Int , beginRow : Int = 0) {
        if oldCount != newCount {
            tableView.beginUpdates()
            Tools.reloadRows(oldCount: oldCount, newCount: newCount, at: tableView, where: sectionEqual)
            tableView.endUpdates()
        }
        
        var indexPaths = [IndexPath]()
        for i in 0 ..<  newCount{
          indexPaths.append(IndexPath.init(row: i + beginRow, section: sectionEqual))
        }
        if indexPaths.count > 0
        {
             tableView.reloadRows(at: indexPaths, with: .none)
        }
       
    }
       
    // 添加毛玻璃
       open class func addBlurSetWith(_ imageView: UIImageView) {
           
           //首先创建一个模糊效果
           let blurEffect = UIBlurEffect(style: .light)
           //接着创建一个承载模糊效果的视图
           let blurView = UIVisualEffectView(effect: blurEffect)
           //设置模糊视图的大小（全屏）
           blurView.frame.size = CGSize(width: AppWidth, height: AppHeight*220/667 + 100)
           //添加模糊视图到页面view上（模糊视图下方都会有模糊效果)
           imageView.addSubview(blurView)
       }
    
    //验证手机号码
     open class func isTelphoneNumber(_ str: String) -> Bool {
          let num = str
          let mobile = "(1)\\d{10}$"
          let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
          return regextestmobile.evaluate(with: num)
      }
      
    
    open class func bytesToAvaiUnit(bytes : CGFloat) -> String{
          if bytes < 10 {
              return "0KB"
          }else if bytes >= 10 && bytes < 1024{
              return  String(format: "%.2fB", bytes)
          }else if bytes >= 10 && bytes < 1024 * 1024{
              return  String(format: "%.2fKB", bytes / 1024)
          }else if bytes >= 1024 * 1024 && bytes < 1024 * 1024 * 1024{
              return  String(format: "%.2fMB", bytes / (1024 * 1024))
          }else{
              return  String(format: "%.2fGB", bytes / (1024 * 1024 * 1024))
          }
      }
    
    
    
    open class func getTextFirstX(_ textCount : Int , spacing : CGFloat , textSize : CGFloat , centreX : CGFloat) -> CGFloat
    {
        if textCount == 0
        {
            return 0
        }
        return centreX - (textCount%2 == 1 ? (CGFloat(textCount - 1)/2*(textSize + spacing) + 0.5 * textSize) : (CGFloat(textCount/2) * (textSize + spacing) - 0.5 * spacing))
    }
    
}

