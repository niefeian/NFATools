//
//  WebViewModel.swift
//  zhouyi
//
//  Created by 聂飞安 on 2019/7/23.
//  Copyright © 2019 聂飞安. All rights reserved.
//

import UIKit

class WebViewModel {
    
    enum WEB_TYPE : Int {
        case 本地网页 = 0, 网页链接, 富文本
    }
    
    var title : String?
    var subVo : AnyObject?
    
    fileprivate var type : Int!
    
    func getWebType() -> Int{
        return type
    }
    // 本地文件名称，不含扩展名
    var localFile : String? {
        didSet {
            type = WEB_TYPE.本地网页.rawValue
        }
    }
    // 本地文件扩展名，如html
    var localFileType : String?
    
    // 网址：当type = 网页链接时设置
    var website : String? {
        didSet {
            type = WEB_TYPE.网页链接.rawValue
        }
    }
    
    var addingPercentEncoding : Bool = true
    // 富文本
    var richContent : String? {
        didSet {
            type = WEB_TYPE.富文本.rawValue
        }
    }
    
    
}

