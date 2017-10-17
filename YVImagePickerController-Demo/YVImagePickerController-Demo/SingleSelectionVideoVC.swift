//
//  SingleSelectionVideoVC.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import AVFoundation
class SingleSelectionVideoVC: UIViewController, YVImagePickerControllerDelegate  {

    
    
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
        pickerVC.yvmediaType = . video
        pickerVC.yvcolumns = 4
        pickerVC.yvIsMultiselect = false
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if info["videodata"] != nil{
            let videoUrl = info["videodata"] as! URL
            
             let playerItem = AVPlayerItem(url:  videoUrl)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer = AVPlayerLayer(player: self.player)
            self.playerLayer.backgroundColor = UIColor.gray.cgColor
            self.playerLayer.frame = CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight-64)
            self.view.layer.addSublayer(self.playerLayer)
            self.player.play()
        }
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

}
