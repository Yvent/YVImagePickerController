//
//  YVImagePickerCell.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class YVImagePickerCell: UICollectionViewCell {
    
    var closeBtnColor: UIColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)
    var imageV: UIImageView!
    var closeBtn: UIButton!
    var timeLab: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        
        contentView.backgroundColor = UIColor.white
        let imagevFrame: CGRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageV = UIImageView(frame: imagevFrame)
        let closeBtnFrame: CGRect = CGRect(x: self.frame.width-3-24, y: 3, width: 24, height: 24)
        closeBtn = UIButton(frame: closeBtnFrame)
        closeBtn.setTitle("♥", for: .selected)
        closeBtn.setTitleColor(closeBtnColor, for: .selected)
        closeBtn.setTitle("", for: .normal)
        closeBtn.isUserInteractionEnabled = false
        let timeLabFrame: CGRect = CGRect(x: 5, y: self.frame.height-20, width: self.frame.width-10, height: 20)
        timeLab = UILabel(frame: timeLabFrame)
        timeLab.textAlignment = .right
        timeLab.textColor = UIColor.white
        timeLab.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(imageV)
        self.contentView.addSubview(closeBtn)
        self.contentView.addSubview(timeLab)
    }
    
    func createImageWithColor(clolr: UIColor,rect: CGRect) -> UIImage{
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(clolr.cgColor)
        context!.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage!
        
    }
}
