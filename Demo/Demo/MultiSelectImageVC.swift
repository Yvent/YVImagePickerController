//
//  MultiSelectImageVC.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit

class MultiSelectImageVC: UIViewController, YVImagePickerControllerDelegate {
    
    var showImagesView: UICollectionView!
    
    let columns: Int = 4
    
    var images = Array<UIImage>()
    
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
        
        let layout = UICollectionViewFlowLayout()
        let yvitemSize = CGSize(width: (ScreenWidth-CGFloat(columns-1))/CGFloat(columns), height: (ScreenWidth-CGFloat(columns-1))/CGFloat(columns))
        layout.itemSize = yvitemSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let imageCollVFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        
        showImagesView = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        showImagesView.backgroundColor = UIColor.white
        
        showImagesView.delegate = self
        showImagesView.dataSource = self
        self.view.addSubview(showImagesView)
        showImagesView.register(YVImagePickerCell.self, forCellWithReuseIdentifier: "YVImagePickerCell")
    }
    func navRightItemClicked()  {
        
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 4
        pickerVC.yvIsMultiselect = true
        pickerVC.delegate = self
        self.present(pickerVC, animated: true, completion: nil)
    }
    
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if info["imagedatas"] != nil{
            let images = info["imagedatas"] as! Array<UIImage>
            self.images = images
            self.showImagesView.reloadData()
        }
    }
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension MultiSelectImageVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImagePickerCell", for: indexPath) as! YVImagePickerCell
        cell.imageV.image = images[indexPath.row]
        return cell
        
    }
    
}
