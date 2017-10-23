//
//  YVLoadinger.swift
//  YVImagePickerController
//
//  Created by Devil on 2017/10/20.
//

import UIKit

class YVLoadinger: NSObject {
    
    static let shared = YVLoadinger()
    private override init() {}
    
    let loadingV: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func show(title: String? = nil) {
        let window: UIWindow = UIApplication.shared.keyWindow!
        window.addSubview(loadingV)
        window.bringSubview(toFront: loadingV)
        loadingV.center = window.center
        loadingV.color = UIColor.black
        loadingV.startAnimating()
    }
    func dismiss() {
        loadingV.stopAnimating()
        loadingV.removeFromSuperview()
    }
}


