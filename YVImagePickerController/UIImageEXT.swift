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
    
    func fixOrientation() -> UIImage {
        if self.imageOrientation == .up  {
            return self
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y:  self.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            break
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .up, .down, .left, .right:
            break
        }
        let ctx: CGContext = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: (self.cgImage?.bitsPerComponent)!, bytesPerRow: 0, space: (self.cgImage?.colorSpace)!, bitmapInfo: (self.cgImage?.bitmapInfo)!.rawValue)!
        ctx.concatenate(transform)
        
        switch self.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width))
            break
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
              break
        }
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
    }
}
extension UIImage {
    
    //裁剪图片
    func yv_cropImage(rect: CGRect) -> UIImage {
        
        let sourceImageRef = self.cgImage
        let newImageRef = sourceImageRef!.cropping(to: rect)
        
        let newImage = UIImage(cgImage: newImageRef!)
        return newImage
    }
    
    /// 异步绘制图像
    func yv_asyncDrawImage(rect: CGRect,
                           isCorner: Bool = false,
                           backColor: UIColor? = UIColor.white,
                           finished: @escaping (_ image: UIImage)->()) {
        
        // 异步绘制图像，可以在子线程进行，因为没有更新 UI
        
        DispatchQueue.global().async {
            
            // 如果指定了背景颜色，就不透明
            UIGraphicsBeginImageContextWithOptions(rect.size, backColor != nil, 1)
            
            let rect = rect
            
            if backColor != nil{
                // 设置填充颜色
                backColor?.setFill()
                UIRectFill(rect)
            }
            
            // 设置圆角 - 使用路径裁切，注意：写设置裁切路径，再绘制图像
            if isCorner {
                let path = UIBezierPath(ovalIn: rect)
                
                // 添加裁切路径 - 后续的绘制，都会被此路径裁切掉
                path.addClip()
            }
            
            // 绘制图像
            self.draw(in: rect)
            
            let result = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            // 主线程更新 UI，提示：有的时候异步也能更新 UI，但是会非常慢！
            
            DispatchQueue.main.async {
                finished(result!)
            }
        }
    }
}
