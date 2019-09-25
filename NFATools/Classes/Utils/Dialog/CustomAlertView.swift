//
//  FVCustomAlertView.swift
//  FVCustomAlertView-Swift
//
//  Ported from FVCustomAlertView(https://github.com/thegameg/FVCustomAlertView)
//
//  Created by Garnel Mao on 1/22/15.

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2014 Francis Visoiu Mistrih.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

/**
FVAlertType definitions
*/
public enum FVAlertType {
    /** A view with a UIActivityIndicator and "Loading..." title. */
    case loading
    /** A view with a checkmark and "Done" title. */
    case done
    /** A view with a cross and "Error" title. */
    case error
    /** A view with an exclamation point and "Warning" title. */
    case warning
    /** A view with a background shadow. */
    case custom
}

/**
* Displays a custom alert view. It can contain either a title or a custom UIView
* The view is customisable and has 4 default modes:
* - FVAlertTypeLoading - displays a UIActivityIndicator
* - FVAlertTypeDone/Error/Warning - displays a checkmark/cross/exclamation point
* - FVAlertTypeCustom - lets the user to customise the view
*/
open class CustomAlertView: UIView {
    
    /**
    * Use singleton pattern to hold the share instance
    * see more: http://code.martinrue.com/posts/the-singleton-pattern-in-swift
    */
    open class var shareInstance: CustomAlertView { 
        return CustomAlertView()
    }

    fileprivate let kInsetValue: CGFloat = 6
    fileprivate let kFinalViewTag: Int = 1337
    fileprivate let kAlertViewTag: Int = 1338
    fileprivate let kFadeOutDuration: TimeInterval = 0.5
    fileprivate let kActivityIndicatorSize: CGFloat = 50
    fileprivate let kOtherIconsSize: CGFloat = 30

    fileprivate var _currentView: UIView?

    /**
    * Getter to the current FVCustomAlertView displayed
    * If no alert view is displayed on the screen, the result will be nil
    */
    open fileprivate(set) var currentView: UIView? {
        get {
            return _currentView
        }

        set {
            _currentView = newValue
        }
    }

    open func showAlertOnView(_ view: UIView, withTitle title: String?, titleColor: UIColor, width: CGFloat, height: CGFloat, backgroundImage: UIImage?, backgroundColor: UIColor?, cornerRadius: CGFloat, shadowAlpha: CGFloat, alpha: CGFloat, contentView: UIView?, type: FVAlertType) {
        // hide current alertView first
        if currentView != nil {
            // must be false
            hideAlertFromView(currentView, fading: false)
        }

        // the view is not added to a window yet
        if view.window == nil {
            return
        }

        if view.viewWithTag(kFinalViewTag) != nil {
            print("Can't add two FVCustomAlertViews on the same view. Hide the current view first.")
            return
        }

        // get window size and position
        let windowRect = UIScreen.main.bounds

        // create the final view with a special tag
        let resultView = UIView(frame: windowRect)
        resultView.tag = kFinalViewTag

        // create a shadow view by adding a black background with custom opacity
        let shadowView = UIView(frame: windowRect)
        shadowView.backgroundColor = UIColor.black
        shadowView.alpha = shadowAlpha
        resultView.addSubview(shadowView)

        // create the main alert view centered
        // with custom width and height
        // and custom background
        // and custom corner radius
        // and custom opacity
        let alertView = UIView(frame: CGRect(x: windowRect.size.width / 2 - width / 2, y: windowRect.size.height / 2 - height / 2, width: width, height: height))
        alertView.tag = kAlertViewTag //set tag to retrieve later

        // set background color
        // if a background image is used, use the image instead
        alertView.backgroundColor = backgroundColor
        if backgroundImage != nil {
            alertView.backgroundColor = UIColor(patternImage: backgroundImage!)
        }
        alertView.layer.cornerRadius = cornerRadius
        alertView.alpha = alpha

        // create the title label centered with multiple lines
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = titleColor

        // set the number of lines to 0 (unlimited)
        // set the maximum size to the label
        // then get the size that fits the maximum size
        titleLabel.numberOfLines = 0
        let requiredSize = titleLabel.sizeThatFits(CGSize(width: width - kInsetValue, height: height - kInsetValue))
        titleLabel.frame = CGRect(x: width / 2 - requiredSize.width / 2, y: kInsetValue, width: requiredSize.width, height: requiredSize.height)
        alertView.addSubview(titleLabel)

        // check wheather the alert is of custom type or not
        // if it is, set the custom view
        if type != .custom || contentView != nil {
            let content = type == .custom ? contentView! : self.contentViewFromType(type)

            content.frame = content.frame.applying(CGAffineTransform(translationX: width / 2 - content.frame.size.width / 2, y: titleLabel.frame.origin.y + titleLabel.frame.size.height + kInsetValue))

            alertView.addSubview(content)
        }

        resultView.addSubview(alertView)

        // tap the alert view to hide and remove it from the superview
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.hideAlertByTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        resultView.addGestureRecognizer(tapGesture)

        // use view's window to let result view cover fullscreen
        view.window?.addSubview(resultView)
        currentView = view
    }

    open func showDefaultLoadingAlertOnView(_ view: UIView, withTitle title: String) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: 100.0, height: 100.0, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .loading)
    }

    open func showDefaultDoneAlertOnView(_ view: UIView, withTitle title: String) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: 100.0, height: 100.0, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .done)
    }

    open func showDefaultErrorAlertOnView(_ view: UIView, withTitle title: String) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: 150.0, height: 100.0, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .error)
    }

    open func showDefaultWarningAlertOnView(_ view: UIView, withTitle title: String) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: 100.0, height: 100.0, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .warning)
    }

    open func showDefaultLoadingAlertOnView(_ view: UIView, withTitle title: String, withSize size: CGSize) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: size.width, height: size.height, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .loading)
    }

    open func showDefaultDoneAlertOnView(_ view: UIView, withTitle title: String, withSize size: CGSize) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: size.width, height: size.height, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .done)
    }

    open func showDefaultErrorAlertOnView(_ view: UIView, withTitle title: String, withSize size: CGSize) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: size.width, height: size.height, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .error)
    }

    open func showDefaultWarningAlertOnView(_ view: UIView, withTitle title: String, withSize size: CGSize) {
        self.showAlertOnView(view, withTitle: title, titleColor: UIColor.black, width: size.width, height: size.height, backgroundImage: nil, backgroundColor: UIColor.lightGray, cornerRadius: 10.0, shadowAlpha: 0.1, alpha: 0.8, contentView: nil, type: .warning)
    }

    open func contentViewFromType(_ type: FVAlertType) -> UIView {
        let content = UIImageView()
        // generate default content view based on the type of the alert
        switch type {
        case .loading:
            let spin = UIActivityIndicatorView(style: .whiteLarge)
            spin.startAnimating()
            return spin
        case .done:
            content.frame = CGRect(x: 0, y: kInsetValue, width: kOtherIconsSize, height: kOtherIconsSize)
            content.image = UIImage(named: "checkmark")
        case .error:
            content.frame = CGRect(x: 0, y: kInsetValue, width: kOtherIconsSize, height: kOtherIconsSize)
            content.image = UIImage(named: "cross")
        case .warning:
            content.frame = CGRect(x: 0, y: kInsetValue, width: kOtherIconsSize, height: kOtherIconsSize)
            content.image = UIImage(named: "warning")
        default:
            // FVAlertTypeCustom never reached
            break
        }

        return content
    }

    open func fadeOutView(_ view: UIView?, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: kFadeOutDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut,
            animations: {
                view?.alpha = 0
                return
            },
            completion: completion
        )
    }

    open func hideAlertFromView(_ view: UIView?, fading: Bool) {
        let alertView = view?.window?.viewWithTag(kFinalViewTag)
        if fading {
            fadeOutView(alertView, completion: { (finished) in
                alertView?.removeFromSuperview()
                return
            })
        } else {
            alertView?.removeFromSuperview()
        }

        // TODO: maybe check view is currentView
        currentView = nil
    }

    @objc open func hideAlertByTap(_ sender: UITapGestureRecognizer) {
        self.fadeOutView(sender.view, completion: {(finished) in
            sender.view?.viewWithTag(self.kFinalViewTag)?.removeFromSuperview()
            self.currentView = nil
        })
    }
}






