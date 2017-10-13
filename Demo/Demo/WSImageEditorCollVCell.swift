//
//  WSImageEditorCollVCell.swift
//  WeiShow
//
//  Created by 周逸文 on 2017/7/12.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

class WSImageEditorCollVCell: UICollectionViewCell {
    
    var imageV: UIImageView!
    
    var closeBtn: UIButton!
    
    var didclickcloseBtn: (()->())!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        contentView.backgroundColor = UIColor.white
//        imageV = UIImageView(yv_named: "",
//                             rd: 0,
//                             bc: UIColor.white,
//                             bdc: UIColor.white.cgColor,
//                             bdw: 0)
        imageV = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        self.contentView.addSubview(imageV)
        closeBtn = UIButton(frame: CGRect(x: self.frame.width-3-24, y: self.frame.height-3-24, width: 24, height: 24))
        closeBtn.setTitle("X", for: .normal)
        closeBtn.addTarget(self, action: #selector(WSImageEditorCollVCell.clickcloseBtn), for: .touchUpInside)
       self.contentView.addSubview(closeBtn)
        
    }
    func clickcloseBtn() {
        self.didclickcloseBtn()
    }
}
