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


public func yvPhonetype() -> String {
    let name = UnsafeMutablePointer<utsname>.allocate(capacity: 1)
    uname(name)
    let machine = withUnsafePointer(to: &name.pointee.machine, { (ptr) -> String? in
        
        let int8Ptr = unsafeBitCast(ptr, to: UnsafePointer<CChar>.self)
        
        return String(validatingUTF8: int8Ptr)
    })
    name.deallocate(capacity: 1)
    if let deviceString = machine {
        switch deviceString {
        //iPhone
        case "iPhone1,1":                return "iPhone 1G"
        case "iPhone1,2":                return "iPhone 3G"
        case "iPhone2,1":                return "iPhone 3GS"
        case "iPhone3,1", "iPhone3,2":   return "iPhone 4"
        case "iPhone4,1":                return "iPhone 4S"
        case "iPhone5,1", "iPhone5,2":   return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":   return "iPhone 5C"
        case "iPhone6,1", "iPhone6,2":   return "iPhone 5S"
        case "iPhone7,1":                return "iPhone 6 Plus"
        case "iPhone7,2":                return "iPhone 6"
        case "iPhone8,1":                return "iPhone 6s"
        case "iPhone8,2":                return "iPhone 6s Plus"
        case "iPhone8,4":                return "iPhone SE"
        case "iPhone9,1":                return "iPhone 7"
        case "iPhone9,2":                return "iPhone 7 Plus"
        case "iPhone10,3":                return "iPhone X"
        case "iPhone10,6":                return "iPhone X"
            
            
            
        case "iPad3,1":                 return "iPad 3"
        case "iPad3,2":                 return "iPad 3"
        case "iPad3,3":                 return "iPad 3"
            
        case "iPad3,4":                 return "iPad 4"
        case "iPad3,5":                 return "iPad 4"
        case "iPad3,6":                 return "iPad 4"
        case "iPad4,1":                 return "iPad Air"
        case "iPad4,2":                 return "iPad Air"
        case "iPad4,3":                 return "iPad Air"
        default:
            return deviceString
        }
    } else {
        return ""
   }
}
