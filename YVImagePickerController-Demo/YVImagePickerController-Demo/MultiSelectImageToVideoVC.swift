//
//  MultiSelectImageToVideoVC.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
import YVImagePickerController
class MultiSelectImageToVideoVC: UIViewController, YVImagePickerControllerDelegate {

    
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        addNavRightItem()
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
    @objc func navRightItemClicked()  {
        
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 4
        pickerVC.yvIsMultiselect = true
        pickerVC.yvdelegate = self
        pickerVC.isEditImages = true
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if info["imagedatas"] != nil{
            let phassets = info["imagedatas"] as! Array<PHAsset>
            
                    let vc = YVImageEditorController()
            
                    vc.phassets = phassets
                      vc.cellsize = CGSize(width: 200, height: 200)
            vc.finished = { [weak self] (fileURL,assets) in
                
                let playerItem = AVPlayerItem(url:  fileURL)
                self?.player = AVPlayer(playerItem: playerItem)
                self?.playerLayer = AVPlayerLayer(player: self?.player)
                self?.playerLayer.backgroundColor = UIColor.gray.cgColor
                self?.playerLayer.frame = CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight-64)
                self?.view.layer.addSublayer((self?.playerLayer)!)
                self?.player.play()
                
                
            }
                    self.present(vc, animated: true, completion: nil)
          
        }
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
