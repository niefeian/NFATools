//
//  ViewController.swift
//  NFATools
//
//  Created by niefeian on 08/15/2019.
//  Copyright (c) 2019 niefeian. All rights reserved.
//

import UIKit
import NFATools
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = SQLiteDB.sharedInstance().execute("CREATE TABLE head(id VARCHAR(36) PRIMARY KEY NOT NULL , json VARCHAR(2000) , key VARCHAR(100) , type  VARCHAR(10));")
              
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

