//
//  YVNavigationView.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/13.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit


public var YVNavColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)
///'class' not have will error
public protocol YVNavigationViewDelegate: class {
    
    func yvdidleftitem()
    func yvdidrightitem()
    func yvsetBackView(backView: UIView)}

public extension YVNavigationViewDelegate where Self: UIViewController{
    func yvdidleftitem() {
        print("Click leftitem")
    }
    func yvdidrightitem() {
        print("Click rightitem")
    }
    public func yvsetBackView(backView: UIView) {
        self.view.addSubview(backView)
        backView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: yvRealHeight())
    }
}

public class YVNavigationView: UIView {

    weak var delegate:YVNavigationViewDelegate!
    
    var leftitem: UIButton = UIButton()
    var centerleftitem: UIButton = UIButton()
    var centeritem: UILabel = UILabel()
    var centerrightitem: UIButton = UIButton()
    var rightitem: UIButton = UIButton()
    
    
  public  init(yv_bc bc: UIColor = YVNavColor,any: Any,title: String = "YVNavigationView",lefttitle: String? = nil,leftnamed: String? = nil,righttitle: String? = nil,rightnamed: String? = nil) {
        super.init(frame: CGRect.zero)
        self.delegate = any as? YVNavigationViewDelegate
        
        initNavigationView(zyw_bc: bc, title: title, lefttitle: lefttitle,leftnamed: leftnamed,righttitle: righttitle, rightnamed: rightnamed)
        addNavigationViewToVC()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addNavigationViewToVC() {
        self.delegate?.yvsetBackView(backView: self)
    }
   public func initNavigationView(zyw_bc bc: UIColor = YVNavColor,title: String = "YVNavigationView",lefttitle: String? = nil,leftnamed: String? = nil,righttitle: String? = nil,rightnamed: String? = nil) {
        backgroundColor = bc
        
        if lefttitle != nil || leftnamed != nil {
            if leftnamed != nil {
                leftitem.setImage(UIImage(named: leftnamed!), for: .normal)
            }
            if lefttitle != nil{
                leftitem.setTitle(lefttitle, for: .normal)
            }
            addSubview(leftitem)
            leftitem.frame = CGRect(x: 5, y: yvRealHeight()-44, width: 44, height: 44)
            leftitem.addTarget(self, action: #selector(YVNavigationView.didleftitem), for: .touchUpInside)
        }
        if rightnamed != nil || righttitle != nil{
            if righttitle != nil {
                rightitem.setTitle(righttitle, for: .normal)
            }
            if rightnamed != nil {
                rightitem.setImage(UIImage(named: rightnamed!), for: .normal)
            }
            addSubview(rightitem)
            rightitem.frame = CGRect(x: ScreenWidth-5-44, y: yvRealHeight()-44, width: 44, height: 44)
            rightitem.addTarget(self, action: #selector(YVNavigationView.didrightitem), for: .touchUpInside)
        }
        
        centeritem.text = title
        centeritem.textAlignment = .center
        centeritem.textColor = UIColor.white
        addSubview(centeritem)
        centeritem.frame = CGRect(x: 50, y: yvRealHeight()-44, width: ScreenWidth-100, height: 44)
    }
    @objc func didleftitem() {
        self.delegate?.yvdidleftitem()
    }
    @objc func didrightitem() {
        self.delegate?.yvdidrightitem()
    }

}
