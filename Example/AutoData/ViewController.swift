//
//  ViewController.swift
//  AutoData
//
//  Created by 335074307@qq.com on 11/06/2019.
//  Copyright (c) 2019 335074307@qq.com. All rights reserved.
//

import UIKit
import AutoData
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        SQLiteUtils.getJosn("12")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

