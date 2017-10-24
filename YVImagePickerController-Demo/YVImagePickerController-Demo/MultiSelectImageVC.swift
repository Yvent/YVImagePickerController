//
//  MultiSelectImageVC.swift
//  Demo
//
//  Created by 周逸文 on 2017/10/12.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import YVImagePickerController
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
        showImagesView.register(YVImagePickerDemoCell.self, forCellWithReuseIdentifier: "YVImagePickerDemoCell")
    }
    @objc func navRightItemClicked()  {
        
        let pickerVC = YVImagePickerController()
        pickerVC.yvmediaType = .image
        pickerVC.yvcolumns = 4
        pickerVC.yvIsMultiselect = true
        pickerVC.yvdelegate = self
        pickerVC.isEditImages = false

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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImagePickerDemoCell", for: indexPath) as! YVImagePickerDemoCell
        cell.imageV.image = images[indexPath.row]
        return cell
        
    }
    
}

class YVImagePickerDemoCell: UICollectionViewCell {
    
    var closeBtnColor: UIColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)
    var imageV: UIImageView!
    var closeBtn: UIButton!
    var timeLab: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        
        contentView.backgroundColor = UIColor.white
        let imagevFrame: CGRect = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        imageV = UIImageView(frame: imagevFrame)
        let closeBtnFrame: CGRect = CGRect(x: self.frame.width-3-24, y: 3, width: 24, height: 24)
        closeBtn = UIButton(frame: closeBtnFrame)
        closeBtn.setTitle("♥", for: .selected)
        closeBtn.setTitleColor(closeBtnColor, for: .selected)
        closeBtn.setTitle("", for: .normal)
        closeBtn.isUserInteractionEnabled = false
        let timeLabFrame: CGRect = CGRect(x: 5, y: self.frame.height-20, width: self.frame.width-10, height: 20)
        timeLab = UILabel(frame: timeLabFrame)
        timeLab.textAlignment = .right
        timeLab.textColor = UIColor.white
        timeLab.font = UIFont.systemFont(ofSize: 12)
        self.contentView.addSubview(imageV)
        self.contentView.addSubview(closeBtn)
        self.contentView.addSubview(timeLab)
    }
    
    func createImageWithColor(clolr: UIColor,rect: CGRect) -> UIImage{
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(clolr.cgColor)
        context!.fill(rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage!
        
    }
}
