//
//  ViewController.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/11.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
class ViewController: UIViewController {

    
    var addImageBtn: UIButton!
    
    var showImagesView: UICollectionView!
    
    let columns: Int = 4
    
    var imagePHAssets: Array<PHAsset> = Array<PHAsset>()
    
    
    lazy var pickerPhotoSize:CGSize = {
        let sreenBounds = UIScreen.main.bounds
        let screenWidth = sreenBounds.width > sreenBounds.height ? sreenBounds.height : sreenBounds.width
        let width = (screenWidth - CGFloat(2) * (CGFloat(2) - 1)) / CGFloat(3)
        return CGSize(width: width, height: width)
    }()
    var photoManage:PHImageManager!
    var photoOption: PHImageRequestOptions!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.brown
        initUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        self.photoManage = PHImageManager()
        self.photoOption = PHImageRequestOptions()
        self.photoOption.resizeMode   = .fast
        self.photoOption.deliveryMode = .opportunistic
        
        
        addImageBtn = UIButton(frame:  CGRect(x: 0, y: 0, width: ScreenWidth, height: 64))
        addImageBtn.setTitle("添加照片", for: .normal)
        addImageBtn.addTarget(self, action: #selector(ViewController.didAddImageBtn), for: .touchUpInside)
        
        let layout = UICollectionViewFlowLayout()
        
        let yvitemSize = CGSize(width: (ScreenWidth-CGFloat(columns-1))/CGFloat(columns), height: (ScreenWidth-CGFloat(columns-1))/CGFloat(columns))
        layout.itemSize = yvitemSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let imageCollVFrame = CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight-64)
        
        showImagesView = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        showImagesView.backgroundColor = UIColor.white
        
        showImagesView.delegate = self
        showImagesView.dataSource = self
        self.view.addSubview(addImageBtn)
        self.view.addSubview(showImagesView)
        showImagesView.register(YVImagePickerCell.self, forCellWithReuseIdentifier: "YVImagePickerCell")
        
    }
    
    func didAddImageBtn() {
        /*
         照片
         每行5列
         多选
         */
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 5
        pickerVC.yvIsMultiselect = true
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    
}
extension ViewController:  YVImagePickerControllerDelegate {
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        //多选照片
        if info["imagedatas"] != nil{
            let phassets = info["imagedatas"] as! Array<PHAsset>
            self.imagePHAssets = phassets
            
            self.showImagesView.reloadData()
        }
        
        
        
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagePHAssets.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImagePickerCell", for: indexPath) as! YVImagePickerCell
        let asset = imagePHAssets[indexPath.row]
        cell.tag = Int(
           
            self.photoManage.requestImage(for: asset, targetSize: pickerPhotoSize, contentMode: .aspectFit, options: photoOption, resultHandler: { (result, info) in
                if result != nil {
                    if (info?["PHImageResultIsDegradedKey"] as! Bool) == true {
                        
                    }else{
                        cell.imageV.image = result!
                    }
                }
            })
        )
        
        return cell
    }

}
