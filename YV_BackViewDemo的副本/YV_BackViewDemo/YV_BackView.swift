//
//  ProtocolsAndSubClassAndExtension.swift
//  Pigs have spread
//
//  Created by 周逸文 on 17/2/15.
//  Copyright © 2017年 Devil. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

//MARK: UI
let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height
func RGB(_ R: CGFloat, G: CGFloat, B: CGFloat) -> UIColor {
    return UIColor(red: R/255.0, green: G/255.0, blue: B/255.0, alpha: 1.0)
}
let YV_BC =  RGB(174, G: 153, B: 90)
///'class' not have will error
protocol YVBackViewDelegate: class {
    
    func zywdidleftitem()
    func zywdidrightitem()
    func zywsetBackView(backView: UIView)}

extension YVBackViewDelegate where Self: UIViewController{
    func zywdidleftitem() {
        print("Click leftitem")
    }
    func zywdidrightitem() {
        print("Click rightitem")
    }

    func zywsetBackView(backView: UIView) {
        self.view.addSubview(backView)
        backView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 64)
    }
}
class YV_BackView: UIView{
    
    weak var delegate:YVBackViewDelegate!
    
    var leftitem: UIButton = UIButton()
    var centerleftitem: UIButton = UIButton()
    var centeritem: UIButton = UIButton()
    var centerrightitem: UIButton = UIButton()
    var rightitem: UIButton = UIButton()
    
    
    init(yv_bc bc: UIColor = YV_BC,any: Any,title: String = "ZYW_BackView",lefttitle: String? = nil,leftnamed: String? = nil,righttitle: String? = nil,rightnamed: String? = nil) {
        super.init(frame: CGRect.zero)
        self.delegate = any as? YVBackViewDelegate
        
        initBackview(zyw_bc: bc, title: title, lefttitle: lefttitle,leftnamed: leftnamed,righttitle: righttitle, rightnamed: rightnamed)
        addBackViewToVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addBackViewToVC() {
        self.delegate?.zywsetBackView(backView: self)
    }
    func initBackview(zyw_bc bc: UIColor = YV_BC,title: String = "ZYW_BackView",lefttitle: String? = nil,leftnamed: String? = nil,righttitle: String? = nil,rightnamed: String? = nil) {
        backgroundColor = bc
        centeritem.setTitle(title, for: .normal)
        addSubview(centeritem)
        centeritem.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.centerX.equalTo(self.snp.centerX)
            make.bottom.equalTo(self)
        }
        if lefttitle != nil || leftnamed != nil {
            if leftnamed != nil {
                leftitem.setImage(UIImage(named: leftnamed!), for: .normal)
            }
            if lefttitle != nil{
            leftitem.setTitle(lefttitle, for: .normal)
            }
            addSubview(leftitem)
            leftitem.snp.makeConstraints { (make) in
                make.left.equalTo(self)
                make.top.equalTo(self).offset(20)
                make.width.equalTo(44)
                make.height.equalTo(44)
            }
            leftitem.addTarget(self, action: #selector(YV_BackView.didleftitem), for: .touchUpInside)
        }
        if rightnamed != nil || righttitle != nil{
            if righttitle != nil {
                 rightitem.setTitle(righttitle, for: .normal)
            }
            if rightnamed != nil {
                rightitem.setImage(UIImage(named: rightnamed!), for: .normal)
            }
            addSubview(rightitem)
            rightitem.snp.makeConstraints { (make) in
                make.right.equalTo(self)
                make.top.equalTo(self).offset(20)
                make.width.equalTo(44)
                make.height.equalTo(44)
            }
            rightitem.addTarget(self, action: #selector(YV_BackView.didrightitem), for: .touchUpInside)
        }
    }
    func didleftitem() {
        self.delegate?.zywdidleftitem()
    }
    func didrightitem() {
        self.delegate?.zywdidrightitem()
    }

}
