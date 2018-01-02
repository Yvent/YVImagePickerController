//
//  YVGlobal.swift
//  YVImagePickerController
//
//  Created by Devil on 2017/10/23.
//

import Foundation



func yvRealHeight() -> CGFloat {
    if ScreenHeight == 812.0  {
        return 88
    }else{
        return 64
    }
}

///  Documents路径
func contentOfDocuments() -> String {
    return NSHomeDirectory().appending("/Documents/")
}
/// 时间戳生成id
func initId() -> TimeInterval{
    return Date().timeIntervalSince1970
}
