//
//  Drop.swift
//  SwiftyDrop
//  通过MessageDialog调用了。
//  Created by MORITANAOKI on 2015/06/18.
//

import UIKit

open class Message {
    public class func show(_ status: String) {
        Drop.down(status, state: .default)

    }
    
    open class func showSuccess(_ status: String) {
        Drop.down(status, state: .success)
    }
    
    open class func showWarning(_ status: String) {
        Drop.down(status, state: .success)
    }
    
    open class func showError(_ status: String) {
        Drop.down(status, state: .error)
    }
    
    open class func showInfo(_ status: String) {
        Drop.down(status, state: .info)
    }
}
