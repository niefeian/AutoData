//
//  AnimationUtils.swift
//  FBSnapshotTestCase
//
//  Created by 聂飞安 on 2020/4/24.
//

import UIKit

public enum AnimationType {
      case 缩放 , 旋转 , 上下
}

open class AnimationUtils{
    
    public class func animation(_ view: UIView  ,  fromValue : Double? , toValue :  Double? , duration : Float?, type : AnimationType ,  repeatCount : Float = HUGE  , autoreverses : Bool = true , isRemovedOnCompletion : Bool = false) -> Void {
        switch type {
        case .旋转:
            self.animation(view, keyPath: "transform.rotation.z", fromValue: fromValue ?? 0, toValue: toValue ?? Double.pi * 2, duration: duration ?? 3, repeatCount: repeatCount, autoreverses: autoreverses, isRemovedOnCompletion: isRemovedOnCompletion)
        case .缩放:
             self.animation(view, keyPath: "transform.scale", fromValue: fromValue ?? 0.9, toValue: toValue ?? 1.1, duration: duration ?? 2, repeatCount: repeatCount, autoreverses: autoreverses, isRemovedOnCompletion: isRemovedOnCompletion)
        case .上下:
              self.animation(view, keyPath: "position.y", fromValue: fromValue ?? 0, toValue: toValue ?? 2, duration: duration ?? 3, repeatCount: repeatCount, autoreverses: autoreverses, isRemovedOnCompletion: isRemovedOnCompletion)
            break
        }
        
    }

   private class func animation(_ view: UIView , keyPath: String , fromValue : Double, toValue :  Double  , duration : Float , repeatCount : Float, autoreverses : Bool, isRemovedOnCompletion : Bool) -> Void {
           // 1.创建动画
           let anim = CABasicAnimation(keyPath: keyPath)
           // 2.设置动画属性
           anim.fromValue = fromValue //  开始时
           anim.toValue = toValue // 结束时
           anim.repeatCount = repeatCount // 重复次数
            anim.duration = CFTimeInterval(duration)
           anim.autoreverses = autoreverses // 动画完成后自动重新开始,默认为NO
           anim.isRemovedOnCompletion = isRemovedOnCompletion
           view.layer.add(anim, forKey: keyPath) // 给需要旋转的view增加动画
    }
    /*
     旋转：transform.rotation、transform.rotation.x、transform.rotation、transform.rotation.z
     缩放：transform.scale、transform.scale.x、transform.scale.y、transform.scale.z
     平移：transform.translation、transform.translation.x、transform.translation.y、transform.translation.z


     改变中心点位置：position、position.x、position.y
     改变Frame相关：bounds.size、bounds.size.width、bounds.size.height、bounds.origin.x、bounds.origin.y


     
     */
    
    /*
     // MARK: - 旋转动画
       public class func fanRotationAnimation(rotationView: UIView , toValue :  Double = Double.pi * 2 , repeatCount : Float = HUGE , duration : Float = 4 , autoreverses : Bool = true , isRemovedOnCompletion : Bool = false) -> Void {
               // 1.创建动画
               let rotationAnim = CABasicAnimation(keyPath: "transform.rotation.z")
               // 2.设置动画属性
               rotationAnim.fromValue = 0 // 开始角度
               rotationAnim.toValue = toValue // 结束角度
               rotationAnim.repeatCount = repeatCount // 重复次数
                rotationAnim.duration = CFTimeInterval(duration)
               rotationAnim.autoreverses = autoreverses // 动画完成后自动重新开始,默认为NO
               rotationAnim.isRemovedOnCompletion = isRemovedOnCompletion //默认是true，切换到其他控制器再回来，动画效果会消失，需要设置成false，动画就不会停了
               rotationView.layer.add(rotationAnim, forKey: nil) // 给需要旋转的view增加动画
        }
        
           // MARK: - 呼吸动画
        public class func scaleAnimation(rotationView: UIView , fromValue : Double = 0.9 , toValue :  Double = 1.1 , repeatCount : Float = HUGE , duration : Float = 1 , autoreverses : Bool = true , isRemovedOnCompletion : Bool = false) -> Void {
                  // 1.创建动画
                  let rotationAnim = CABasicAnimation(keyPath: "transform.scale")
                  // 2.设置动画属性
                  rotationAnim.fromValue = fromValue //  开始时的倍率
                  rotationAnim.toValue = toValue // 结束时的倍率
                  rotationAnim.repeatCount = repeatCount // 重复次数
                   rotationAnim.duration = CFTimeInterval(duration)
                  rotationAnim.autoreverses = autoreverses // 动画完成后自动重新开始,默认为NO
                  rotationAnim.isRemovedOnCompletion = isRemovedOnCompletion //默认是true，切换到其他控制器再回来，动画效果会消失，需要设置成false，动画就不会停了
                  rotationView.layer.add(rotationAnim, forKey: "scale-layer") // 给需要旋转的view增加动画
           }
        
     
     */
}
