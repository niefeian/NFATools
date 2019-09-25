//
//  GSMessage.swift
//  GSMessagesExample
//
//  Created by Gesen on 15/7/10.
//  Copyright (c) 2015年 Gesen. All rights reserved.
//

import UIKit

public enum MessageDialogType {
    case success
    case error
    case warning
    case info
}

public enum GSMessagePosition {
    case top
    case bottom
    case topSubStatusBar // 上面滑下来的提醒，减掉了状态栏的高度44+20
}

public enum MessageDialogAnimation {
    case slide
    case fade
}

public enum MessageDialogOption {
    case animation(MessageDialogAnimation)
    case animationDuration(TimeInterval)
    case autoHide(Bool)
    case autoHideDelay(Double) // Second
    case height(CGFloat)
    case hideOnTap(Bool)
    case position(GSMessagePosition)
    case textColor(UIColor)
    case textPadding(CGFloat)
}

extension UIViewController {
    
    public func showMessage(_ text: String, type: MessageDialogType, options: [MessageDialogOption]?) {
        MessageDialog.showMessageAddedTo(view, text: text, type: type, options: options)
    }
    
    public func hideMessage() {
        view.hideMessage()
    }
    
    public func showSuccessMessage(_ text : String) {
//        showMessage(text, type: .Success, options: nil)
        Message.showSuccess(text)
    }
    
    public func showErrorMessage(_ text : String) {
//        showMessage(text, type: .Error, options: nil)
        Message.showError(text)
    }
    
    public func showWarningMessage(_ text : String) {
//        showMessage(text, type: .Warning, options: nil)
        Message.showWarning(text)
    }
    public func showInfoMessage(_ text : String) {
//        showMessage(text, type: .Info, options: nil)
        Message.showInfo(text)
    }
}

extension UIView {
    public func showMessage(_ text: String, type: MessageDialogType, options: [MessageDialogOption]?) {
        MessageDialog.showMessageAddedTo(self, text: text, type: type, options: options)
    }
    
    public func hideMessage() {
        installedMessage?.hide()
    }
    
}

open class MessageDialog {
    
    public static var font: UIFont = UIFont.systemFont(ofSize: 14)
    public static var successBackgroundColor: UIColor = UIColor(red: 142.0/255, green: 183.0/255, blue: 64.0/255, alpha: 0.95)
    public static var warningBackgroundColor: UIColor = UIColor(red: 230.0/255, green: 189.0/255, blue: 1.0/255, alpha: 0.95)
    public static var errorBackgroundColor: UIColor = UIColor(red: 219.0/255, green: 36.0/255, blue: 27.0/255, alpha: 0.70)
    public static var infoBackgroundColor: UIColor = UIColor(red: 44.0/255, green: 187.0/255, blue: 255.0/255, alpha: 0.90)
    
    class func showMessageAddedTo(_ view: UIView, text: String, type: MessageDialogType, options: [MessageDialogOption]?) {
        if view.installedMessage != nil && view.uninstallMessage == nil { view.hideMessage() }
        if view.installedMessage == nil {
            MessageDialog(view: view, text: text, type: type, options: options).show()
        }
    }
    
    func show() {
        
        if view?.installedMessage != nil { return }
        
        view?.installedMessage = self
        view?.addSubview(message)
        
        if animation == .fade {
            message.alpha = 0
            UIView.animate(withDuration: animationDuration, animations: { self.message.alpha = 1 }) 
        }
            
        else if animation == .slide && (position == .top || position == .topSubStatusBar) {
            message.transform = CGAffineTransform(translationX: 0, y: -messageHeight)
            UIView.animate(withDuration: animationDuration, animations: { self.message.transform = CGAffineTransform(translationX: 0, y: 0) }) 
        }
            
        else if animation == .slide && position == .bottom {
            message.transform = CGAffineTransform(translationX: 0, y: height)
            UIView.animate(withDuration: animationDuration, animations: { self.message.transform = CGAffineTransform(translationX: 0, y: 0) }) 
        }
        
        if autoHide { GCDAfter(autoHideDelay) { self.hide() } }

    }
    
    func hide() {
        
        if view?.installedMessage !== self || view?.uninstallMessage != nil { return }
        
        view?.uninstallMessage = self
        view?.installedMessage = nil
        
        if animation == .fade {
            UIView.animate(withDuration: self.animationDuration,
                animations: { [weak self] in if let this = self { this.message.alpha = 0 } },
                completion: { [weak self] finished in self?.removeFromSuperview() }
            )
        }
            
        else if animation == .slide && (position == .top || position == .topSubStatusBar) {
            UIView.animate(withDuration: self.animationDuration,
                animations: { [weak self] in if let this = self { this.message.transform = CGAffineTransform(translationX: 0, y: -this.messageHeight) } },
                completion: { [weak self] finished in self?.removeFromSuperview() }
            )
        } 
            
        else if animation == .slide && position == .bottom {
            UIView.animate(withDuration: self.animationDuration,
                animations: { [weak self] in if let this = self { this.message.transform = CGAffineTransform(translationX: 0, y: this.height) } },
                completion: { [weak self] finished in self?.removeFromSuperview() }
            )
        }
        
    }
    
    fileprivate weak var view: UIView?
    fileprivate var message: UIView!
    fileprivate var messageText: UILabel!
    fileprivate var animation: MessageDialogAnimation = .slide
    fileprivate var animationDuration: TimeInterval = 0.3
    fileprivate var autoHide: Bool = true
    fileprivate var autoHideDelay: Double = 2
    fileprivate var backgroundColor: UIColor!
    fileprivate var height: CGFloat = 44
    fileprivate var hideOnTap: Bool = true
    fileprivate var offsetY: CGFloat = 0
    fileprivate var position: GSMessagePosition = .top
    fileprivate var textColor: UIColor = UIColor.white
    fileprivate var textPadding: CGFloat = 30
    fileprivate var y: CGFloat = 0
    
    fileprivate var messageHeight: CGFloat { return offsetY + height }
    
    fileprivate init(view: UIView, text: String, type: MessageDialogType, options: [MessageDialogOption]?) {
        
        switch type {
        case .success:  backgroundColor = MessageDialog.successBackgroundColor
        case .warning:  backgroundColor = MessageDialog.warningBackgroundColor
        case .error:    backgroundColor = MessageDialog.errorBackgroundColor
        case .info:     backgroundColor = MessageDialog.infoBackgroundColor
        }
        
        if let options = options {
            for option in options {
                switch (option) {
                case let .animation(value): animation = value
                case let .animationDuration(value): animationDuration = value
                case let .autoHide(value): autoHide = value
                case let .autoHideDelay(value): autoHideDelay = value
                case let .height(value): height = value
                case let .hideOnTap(value): hideOnTap = value
                case let .position(value): position = value
                case let .textColor(value): textColor = value
                case let .textPadding(value): textPadding = value
                }
            }
        }
        
        switch position {
        case .top:
//            if let inViewController = inViewController {
//                var navigation = inViewController.navigationController ?? (inViewController as? UINavigationController)
//                var navigationBarHidden = (navigation?.navigationBarHidden ?? true)
//                var navigationBarTranslucent = (navigation?.navigationBar.translucent ?? false)
//                var statusBarHidden = UIApplication.sharedApplication().statusBarHidden
//                if !navigationBarHidden && navigationBarTranslucent && !statusBarHidden { offsetY+=20 }
//                if !navigationBarHidden && navigationBarTranslucent { offsetY+=44; }
//                if (navigationBarHidden && !statusBarHidden) { offsetY+=20 }
//            }
            offsetY+=20
            offsetY+=44;
        case .bottom:
            y = view.bounds.size.height - height
        case .topSubStatusBar:
            offsetY = 0
        }
        
        message = UIView(frame: CGRect(x: 0, y: y, width: view.bounds.size.width, height: messageHeight))
        message.backgroundColor = backgroundColor
        
        messageText = UILabel(frame: CGRect(x: textPadding, y: offsetY, width: message.bounds.size.width - textPadding * 2, height: height))
        messageText.text = text
        messageText.font = MessageDialog.font
        messageText.textColor = textColor
        messageText.textAlignment = .center
        message.addSubview(messageText)
        
        if hideOnTap { message.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MessageDialog.handleTap(_:)))) }
        
        self.view = view
    }
    
    @objc fileprivate func handleTap(_ tapGesture: UITapGestureRecognizer) {
        hide()
    }
    
    fileprivate func removeFromSuperview() {
        message.removeFromSuperview()
        view?.uninstallMessage = nil
    }
    
}

extension UIView {
    
    fileprivate var installedMessage: MessageDialog? {
        get { return objc_getAssociatedObject(self, &installedMessageKey) as? MessageDialog }
        set {
        objc_setAssociatedObject(self, &installedMessageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
    
    fileprivate var uninstallMessage: MessageDialog? {
        get { return objc_getAssociatedObject(self, &uninstallMessageKey) as? MessageDialog }
        set {
            objc_setAssociatedObject(self, &uninstallMessageKey, newValue,  objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
    }
    
}

private var installedMessageKey = ""
private var uninstallMessageKey = ""

private func GCDAfter(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
