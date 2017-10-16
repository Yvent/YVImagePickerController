//
//  UIImageEXT.swift
//  Demo
//
//  Created by Devil on 2017/10/16.
//  Copyright © 2017年 YV. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{
    func fixOrientation1() -> UIImage {
        if self.imageOrientation == .up  {
            return self
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        
        switch self.imageOrientation {
        case .down:
            print("down")
        case .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left:
            print("left")
        case .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case .right:
            print("right")
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y:  self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            break
        case .up:
            print("up")
        case .upMirrored:
            print("upMirrored")
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored:
            print("upMirrored")
        case .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored:
            print("leftMirrored")
        case .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up:
            print("up")
        case .down:
            print("down")
        case .left:
            print("left")
        case .right:
            print("right")
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (self.cgImage?.colorSpace)!, bitmapInfo: (self.cgImage?.bitmapInfo)!.rawValue)!
        ctx.concatenate(transform)
        
        switch self.imageOrientation {
        case .left:
            print("left")
        case .leftMirrored:
            print("leftMirrored")
        case .right:
            print("right")
        case .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            break
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        }
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)

        return img
    }
    
    
}
