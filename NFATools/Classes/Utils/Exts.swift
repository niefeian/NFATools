//
//  MD5Helper.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//


import Foundation
import UIKit
public extension String {
    
    // 从0开始截取到to的位置。如果to的位置超过文本的长度，返回原始文本。注意需要截取到的位置是原始位置+1，如20160101要截取年度，substringToIndex(5).注意参数是5，不是4
    public func substringToIndex(_ to : Int) -> String {
        
        var temp : NSString = self as NSString
        let length = temp.length
        if to > length {
            return self
        }
        temp = temp.substring(to: to - 1) as NSString
        return temp as String
    }
    
   public func subString(start:Int, length:Int = -1)->String {
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

public extension Dictionary {
    public mutating func addAll(_ dic : Dictionary) {
        for (k , v) in dic {
            self[k] = v
        }
    }
}

public extension CGFloat {
    var valueBetweenZeroAndOne: CGFloat {
        return abs(self) > 1 ? 1 : abs(self)
    }
}

public extension UIImage {
    public class func sharedCache() -> NSCache<AnyObject, AnyObject>!
    {
        return NSCache()
    }
}

/// 对UIView的扩展
public extension UIView {
    /// 宽度
    public var width: CGFloat {
        return self.frame.size.width
    }
    ///高度
    public var height: CGFloat {
        return self.frame.size.height
    }
}
