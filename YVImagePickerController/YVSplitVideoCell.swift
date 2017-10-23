//
//  YVSplitVideoCell.swift
//  Pods-YVImagePickerController-Demo
//
//  Created by Devil on 2017/10/20.
//

import UIKit

class YVSplitVideoCell: UICollectionViewCell {
    
    var imageV: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func initUI() {
        contentView.backgroundColor = UIColor.white
        imageV = UIImageView(image: UIImage(named: "contour_off_icon"))
        imageV.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
        contentView.addSubview(imageV)
    }
}
