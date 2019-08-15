//
//  UserDefaultsUtil.swift
//  Pods-Tools_Example
//
//  Created by 聂飞安 on 2019/8/15.
//

import Foundation
open class UserDefaultsUtils {
    
    /// 是否在分组里存在
    open class func existsInGroup(_ group : String, key : String) -> Bool {
        let groups = UserDefaults.standard.value(forKey: group)
        if groups == nil {
            return false
        }
        
        let dic = groups as! NSMutableDictionary
        let v = dic.object(forKey: key)
        if v == nil {
            return false
        }
        return v! as! Bool
    }
    
    /// 在分组中进行完结
    open class func finishInGroup(_ group : String, key : String) {
        let groups = UserDefaults.standard.value(forKey: group)
        if groups == nil {
            let dic = NSMutableDictionary()
            dic.setValue(true, forKey: key)
            
            UserDefaults.standard.set(dic, forKey: group)
        } else {
            let oldDic = groups as! NSDictionary
            let dic = NSMutableDictionary(dictionary: oldDic)
            dic.setValue(true, forKey: key)
            UserDefaults.standard.set(dic, forKey: group)
        }
    }
     
}
