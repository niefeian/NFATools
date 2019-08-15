//
//  ProgressHUD.swift
//  cloudclass
//  进度显示
//  Created by jacty on 15/8/6.
//  Copyright © 2015年 tizi. All rights reserved.
//

import Foundation
import UIKit

///
/// @brief 样式
enum ProgressStyle {
    case blackStyle /// 黑色风格
    case whiteStyle /// 白色风格
}

///
/// @brief 定制显示通知的视图HUD
///
open class MsgProgress: UIView {
    
    var hud: UIView?
    var spinner: UIActivityIndicatorView?
    var imageView: UIImageView?
    var titleLabel: UILabel?
    
    ///
    /// private 属性
    ///
    fileprivate let statusFont = UIFont.boldSystemFont(ofSize: 16.0)
    fileprivate var statusColor: UIColor!
    fileprivate var spinnerColor: UIColor!
    fileprivate var bgColor: UIColor!
    fileprivate var successImage: UIImage!
    fileprivate var errorImage: UIImage!
    
    static var progress : MsgProgress!
    ///
    /// @brief 单例方法，只允许内部调用
    open class func sharedInstance() ->MsgProgress {
        if progress == nil {
            progress = MsgProgress(frame: UIScreen.main.bounds)
            progress.setStyle(ProgressStyle.whiteStyle)
        }
        
        return progress
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hud = nil
        spinner = nil
        imageView = nil
        titleLabel = nil
        self.alpha = 0.0
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// 公开方法
    ///
    
    /// 显示信息
    open class func show(_ status: String) {
        sharedInstance().configureHUD(status, image: nil, isSpin: true, isHide: false)
    }
    
    /// 显示成功信息
    open class func showSuccess(_ status: String) {
        sharedInstance().configureHUD(status, image: sharedInstance().successImage, isSpin: false, isHide: true)
    }
    
    /// 显示出错信息
    open class func showError(_ status: String) {
        sharedInstance().configureHUD(status, image: sharedInstance().errorImage, isSpin: false, isHide: true)
    }
    
    open class func showMsg(_ status : String, image : UIImage?, isHide : Bool) {
        var isSpin = false
        if image == nil {
            isSpin = true
        }
        sharedInstance().configureHUD(status, image: image, isSpin: isSpin, isHide: isHide)
    }
    
    /// 隐藏
    open class func dismiss() {
        sharedInstance().hideHUD(true)
    }
    /// 立刻隐藏
    open class func dismissImmediately() {
        sharedInstance().hideHUD(false)
    }
    
    ///
    /// 私有方法
    ///
    
    ///
    /// @brief 创建并配置HUD
    fileprivate func configureHUD(_ status: String?, image: UIImage?, isSpin: Bool, isHide: Bool) {
        configureProgressHUD()
        
        /// 标题
        if status == nil {
            titleLabel!.isHidden = true
        } else {
            titleLabel!.text = status!
            titleLabel!.isHidden = false
        }
        // 图片
        if image == nil {
            imageView?.isHidden = true
        } else {
            imageView?.isHidden = false
            imageView?.image = image
        }
        
        // spin
        if isSpin {
            spinner?.startAnimating()
        } else {
            spinner?.stopAnimating()
        }
        rotate(nil)
        addjustSize()
        showHUD()
        
        if isHide {
            Thread.detachNewThreadSelector(#selector(self.hideWhenTimeout), toTarget: self, with: nil)
        }
    }
    
    ///
    /// @brief 设置风格样式，默认使用的是黑色的风格，如果需要改成白色的风格，请在内部修改样式
    fileprivate func setStyle(_ style: ProgressStyle) {
        switch style {
        case .blackStyle:
            statusColor = UIColor.white
            spinnerColor = UIColor.white
            bgColor = UIColor(white: 0, alpha: 0.8)
            successImage = UIImage(named: "success.png")
            errorImage = UIImage(named: "error.png")
            break
        case .whiteStyle:
            statusColor = UIColor.white
            spinnerColor = UIColor.white
            bgColor = UIColor(red: 56 / 255.0, green: 56 / 255.0, blue: 56 / 255.0, alpha: 0.8)
            successImage = UIImage(named: "success.png")
            errorImage = UIImage(named: "error.png")
            break
        default:
            break
        }
    }
    
    ///
    /// @brief 获取窗口window
    fileprivate func getWindow() ->UIWindow {
        if let delegate: UIApplicationDelegate = UIApplication.shared.delegate {
            if let window = delegate.window {
                return window!
            }
        }
        
        return UIApplication.shared.keyWindow!
    }
    
    ///
    /// @brief 创建HUD
    fileprivate func configureProgressHUD() {
        if hud == nil {
            hud = UIView(frame: CGRect.zero)
            hud?.backgroundColor = bgColor
            hud?.layer.cornerRadius = 10
            hud?.layer.masksToBounds = true
            
            /// 监听设置方向变化
            NotificationCenter.default.addObserver(self,
                selector: #selector(self.rotate(_:)),
                name: UIDevice.orientationDidChangeNotification,
                object: nil)
        }
        
        if hud!.superview == nil {
            getWindow().addSubview(hud!)
        }
        
        if spinner == nil {
            spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
            spinner!.color = spinnerColor
            spinner!.hidesWhenStopped = true
        }
        
        if spinner!.superview == nil {
            hud!.addSubview(spinner!)
        }
        
        if imageView == nil {
            imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        }
        
        if imageView!.superview == nil {
            hud!.addSubview(imageView!)
        }
        
        if titleLabel == nil {
            titleLabel = UILabel(frame: CGRect.zero)
            titleLabel?.backgroundColor = UIColor.clear
            titleLabel?.font = statusFont
            titleLabel?.textColor = statusColor
            titleLabel?.baselineAdjustment = UIBaselineAdjustment.alignCenters
            titleLabel?.numberOfLines = 0
            titleLabel?.textAlignment = NSTextAlignment.center
            titleLabel?.adjustsFontSizeToFitWidth = false
        }
        
        if titleLabel!.superview == nil {
            hud!.addSubview(titleLabel!)
        }
    }
    
    ///
    /// @brief 释放资源
    fileprivate func destroyProgressHUD() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        
        titleLabel?.removeFromSuperview()
        titleLabel = nil
        
        spinner?.removeFromSuperview()
        spinner = nil
        
        imageView?.removeFromSuperview()
        imageView = nil
        
        hud?.removeFromSuperview()
        hud = nil
    }
    
    ///
    /// @brief 设置方向变化通知处理
    @objc func rotate(_ sender: Notification?) {
        var rotation: CGFloat = 0.0
        switch UIApplication.shared.statusBarOrientation {
        case UIInterfaceOrientation.portrait:
            rotation = 0.0
            break
        case .portraitUpsideDown:
            rotation = CGFloat(Double.pi)
            break
        case .landscapeLeft:
            rotation = -CGFloat(Double.pi/2)
            break
        case .landscapeRight:
            rotation = CGFloat(Double.pi/2)
            break
        default:
            break
        }
        
        hud?.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    ///
    /// @brief 调整大小
    fileprivate func addjustSize() {
        var rect = CGRect.zero
        var width: CGFloat = 100.0
        var height: CGFloat = 100.0
        
        /// 计算文本大小
        if titleLabel!.text != nil {
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = NSLineBreakMode.byCharWrapping
            let attributes = [NSAttributedString.Key.font: statusFont, NSAttributedString.Key.paragraphStyle: style.copy()]
            let option = NSStringDrawingOptions.usesLineFragmentOrigin
            let text: NSString = NSString(cString: titleLabel!.text!.cString(using: String.Encoding.utf8)!,
                encoding: String.Encoding.utf8.rawValue)!
            rect = text.boundingRect(with: CGSize(width: 160, height: 260), options: option, attributes: attributes, context: nil)
            rect.origin.x = 12
            rect.origin.y = 66
            
            width = rect.size.width + 24
            height = rect.size.height + 80
            
            if width < 100 {
                width = 100
                rect.origin.x = 0
                rect.size.width = 100
            }
        }
        let kScreenWidth = UIScreen.main.applicationFrame.size.width
        let kScreenHeight = UIScreen.main.applicationFrame.size.height
        hud!.center = CGPoint(x: kScreenWidth / 2, y: kScreenHeight / 2)
        let h = titleLabel!.text ?? "" == "" ? height / 2 : 36
        imageView!.center = CGPoint(x: width / 2, y: h)
        
        if titleLabel?.text ?? "" == "" && imageView?.isHidden ?? true {
            hud!.bounds = CGRect(x: 0, y: 0, width: 50, height: 50)
            spinner!.center = CGPoint(x: 25, y: 25)
        } else {
            hud!.bounds = CGRect(x: 0, y: 0, width: width, height: height)
            spinner!.center = CGPoint(x: width / 2, y: h)
        }
        
        
        
        titleLabel!.frame = rect
    }
    
    ///
    /// @brief 显示
    fileprivate func showHUD() {
        if self.alpha == 0.0 {
            self.alpha = 1.0
            
            hud!.alpha  = 0.0
            self.hud!.transform = self.hud!.transform.scaledBy(x: 1.4, y: 1.4)
            UIView.animateKeyframes(withDuration: 0.15,
                delay: 0.0,
                options: UIView.KeyframeAnimationOptions.allowUserInteraction,
                animations: { () -> Void in
                    self.hud!.transform = self.hud!.transform.scaledBy(x: 1.0 / 1.4, y: 1.0 / 1.4)
                    self.hud!.alpha = 1
                        
                }, completion: { (isFinished) -> Void in
            })
        }
    }
    
    ///
    /// @brief 隐藏
    fileprivate func hideHUD(_ animator : Bool = true) {
        if self.alpha == 1.0 {
            if animator {
                UIView.animateKeyframes(withDuration: 0.2,
                                                    delay: 0.0,
                                                    options: UIView.KeyframeAnimationOptions.allowUserInteraction,
                                                    animations: { () -> Void in
                                                        self.hud?.transform = self.hud!.transform.scaledBy(x: 0.35, y: 0.35)
                                                        self.hud?.alpha = 0.0
                    }, completion: { (isFinished) -> Void in
                        self.destroyProgressHUD()
                        self.alpha = 0.0
                })
            } else {
                self.hud?.transform = self.hud!.transform.scaledBy(x: 0.35, y: 0.35)
                self.hud?.alpha = 0.0
                self.destroyProgressHUD()
                self.alpha = 0.0
            }
        }
    }
    
    ///
    /// @brief 在指定时间内隐藏
    @objc func hideWhenTimeout() {
        autoreleasepool { () -> () in
            // 必须判断，否则可能会存在bug，如以下场景：下拉刷新数据，如果已经到了最后一条数据，此时提示，但是一直刷新，就有可能弹出的titleLabel被之前的线程干掉了。此时titleLabel=nil
            if self.titleLabel != nil {
                
                DispatchQueue.main.async {
                    let length = self.titleLabel!.text!.lengthOfBytes(using: String.Encoding.utf8)//countElements(self.titleLabel!.text!)
                    
                    var sleepTime: TimeInterval = TimeInterval(length) * 0.04 + 0.5
                    if length == 0 {
                        sleepTime = 1.2
                    }
                    
                    Thread.sleep(forTimeInterval: sleepTime)
                    self.hideHUD()
                }
            }
        }
    }
}
