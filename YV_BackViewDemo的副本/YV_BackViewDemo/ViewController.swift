//
//  ViewController.swift
//  YV_BackViewDemo
//
//  Created by 周逸文 on 2017/7/31.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

class ViewController: UIViewController,YVBackViewDelegate {

    
    var backview: YV_BackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        backview = YV_BackView(yv_bc: YV_BC, any: self, title: "你好", lefttitle: "返回", leftnamed: nil, righttitle: "完成", rightnamed: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

