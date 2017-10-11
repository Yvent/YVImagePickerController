//
//  ViewController.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/11.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
class ViewController: UIViewController,YVImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        /*
         照片
         每行4列
         单选
         */
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 4
        pickerVC.yvIsMultiselect = false
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
        
        
        /*
         照片
         每行5列
         多选
         */
//        let pickerVC = YVImagePickerController()
//        pickerVC.yvmediaType = .image
//        pickerVC.yvcolumns = 5
//        pickerVC.yvIsMultiselect = true
//        pickerVC.delegate = self
//        self.present(pickerVC, animated: true, completion: nil)
        
        
        /*
         视频
         每行5列
         单选
         */
//        let pickerVC = YVImagePickerController()
//        pickerVC.yvmediaType = .video
//        pickerVC.yvcolumns = 5
//        pickerVC.yvIsMultiselect = false
//        pickerVC.delegate = self
//        self.present(pickerVC, animated: true, completion: nil)



    }
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
         picker.dismiss(animated: true, completion: nil)
        //单选照片
        if info["imagedata"] != nil{
            let image =  info["imagedata"] as! UIImage
            print("\(image)")
            
        }
//        //单选视频
//        else  if info["videodata"] != nil{
//            let url = info["videodata"] as! URL
//            
//        }
//        //多选照片
//        else  if info["imagedatas"] != nil{
//            let phassets = info["imagedatas"] as! Array<PHAsset>
//            
//            
//        }
        
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

