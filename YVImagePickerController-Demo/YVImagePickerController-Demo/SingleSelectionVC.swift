//
//  SingleSelectionImageVC.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import YVImagePickerController
class SingleSelectionImageVC: UIViewController, YVImagePickerControllerDelegate {
    
    
    var showImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        addNavRightItem()
        initUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func addNavRightItem() {
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 70, height: 35)
        btn.setTitle("添加", for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.addTarget(self, action: #selector(navRightItemClicked), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    func initUI() {
        showImageView = UIImageView(frame: CGRect(x: 40, y: 80, width: ScreenWidth-80, height: ScreenHeight-100))
        showImageView.backgroundColor = UIColor.gray
        self.view.addSubview(showImageView)
    }
    @objc func navRightItemClicked()  {
 
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 5
        pickerVC.yvIsMultiselect = false
        pickerVC.yvdelegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if info["imagedata"] != nil{
            let image = info["imagedata"] as! UIImage
            
            self.showImageView.image = image
        }
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
