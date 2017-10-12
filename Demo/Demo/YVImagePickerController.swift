
//
//  Created by 周逸文 on 2017/10/11.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
import PhotosUI
import SVProgressHUD

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

let YvNavColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)


protocol YVImagePickerControllerDelegate: class {
    func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController)
}
public enum yvMediaType: Int {
    case video
    case image
}
public enum yvPHAuthorizationStatus : Int {
    case yvnotDetermined
    case yvrestricted
    case yvdenied
    case yvauthorized
}


class YVImagePickerController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource{
    
    
    ///导出视频的路径
    var yvOutputPath: String = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! + "/YV_Available.mp4"
    ///多选时最大张数
    var yvmaxSelected = 10
    ///列数
    var yvcolumns = 4
    ///导航栏背景色
    var topViewColor: UIColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)
    ///过滤相册时上下icon
    var arrowUpName: String?
    var arrowDownName: String?
    ///媒体类型：照片或视频
    var yvmediaType: yvMediaType = .image
    ///是否多选，默认单选
    var yvIsMultiselect: Bool! = false
    var topView: UIView!
    weak var delegate: YVImagePickerControllerDelegate!
    
    //全部相册的数组
    private(set) var photoAlbums    = [[String: PHFetchResult<PHAsset>]]()
    lazy var pickerPhotoSize:CGSize = {
        let sreenBounds = UIScreen.main.bounds
        let screenWidth = sreenBounds.width > sreenBounds.height ? sreenBounds.height : sreenBounds.width
        let width = (screenWidth - CGFloat(2) * (CGFloat(2) - 1)) / CGFloat(3)
        return CGSize(width: width, height: width)
    }()
    var cellsize: CGSize!
    private var yvPHstatus: yvPHAuthorizationStatus!
    
    private var photoManage:PHImageManager!
    private var photoOption: PHImageRequestOptions!
    private let photoCreationDate = "modificationDate"
    var assets: [String: PHFetchResult<PHAsset>]!
    var selectedAssets = Array<PHAsset>()
    
    var nextBtn: UIButton!
    var photoAlbumBtn: UIButton!
    var imageCollV: UICollectionView!
    var photoAlbumTab: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        createYVTopView()
        photoAuthorization()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        if  self.yvPHstatus == yvPHAuthorizationStatus.yvdenied {
            toAuthorization()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    deinit {
        print("remove")
    }
    
    //相册授权
    func photoAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        // 用户拒绝,提示开启
        case .denied:
            self.yvPHstatus = yvPHAuthorizationStatus.yvdenied
            break
        // 尚未请求,立即请求
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                // 用户授权
                if status == .authorized {
                    self.yvPHstatus = yvPHAuthorizationStatus.yvauthorized
                    DispatchQueue.main.async {
                        self.initoptions()
                        self.initUI()
                    }
                }else{
                    self.yvPHstatus = yvPHAuthorizationStatus(rawValue: status.hashValue)
                }
            })
            break
        //  APP禁止使用相册权限认证
        case .restricted:
            self.yvPHstatus = yvPHAuthorizationStatus.yvrestricted
            break
        case .authorized:
            // 用户已授权
            self.yvPHstatus = yvPHAuthorizationStatus.yvauthorized
            DispatchQueue.main.async {
                self.initoptions()
                self.initUI()
            }
            break
        }
    }
    
    private func initoptions() {
        
        
        self.photoManage = PHImageManager()
        self.photoOption = PHImageRequestOptions()
        self.photoOption.resizeMode   = .fast
        self.photoOption.deliveryMode = .opportunistic
        //创建一个PHFetchOptions对象检索照片
        let options = PHFetchOptions()
        //通过创建时间来检索
        options.sortDescriptors = [NSSortDescriptor.init(key: photoCreationDate , ascending: false)]
        //通过数据类型来检索，这里为只检索照片
        //      options.predicate =  yvpredicate
        
        switch yvmediaType {
        case .video:
            options.predicate = NSPredicate.init(format: "mediaType in %@", [ PHAssetMediaType.video.rawValue])
        case .image:
            options.predicate = NSPredicate.init(format: "mediaType in %@", [PHAssetMediaType.image.rawValue])
        }
        
        //通过检索条件检索出符合检索条件的所有数据，也就是所有的照片
        let allResult = PHAsset.fetchAssets(with: options)
        //获取用户创建的相册
        let userResult = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        //获取智能相册
        let smartResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
        //将获取的相册加入到相册的数组中
        photoAlbums.append(["全部照片": allResult])
        userResult.enumerateObjects(options: .concurrent) { (collection, index, stop) in
            let assetcollection = collection as! PHAssetCollection
            //通过检索条件从assetcollection中检索出结果
            let assetResult = PHAsset.fetchAssets(in: assetcollection, options: options)
            if assetResult.count != 0 {
                self.photoAlbums.append([assetcollection.localizedTitle!:assetResult])
            }
        }
        smartResult.enumerateObjects(options: .concurrent) { (collection, index, stop) in
            //通过检索条件从assetcollection中检索出结果
            let assetResult = PHAsset.fetchAssets(in: collection, options: options)
            if assetResult.count != 0 {
                self.photoAlbums.append([collection.localizedTitle!:assetResult])
                if self.yvmediaType == .video {
                    if collection.localizedTitle! == "视频" ||  collection.localizedTitle! == "Videos"{
                        self.assets = [collection.localizedTitle!:assetResult]
                    }
                }
            }
        }
    }
    
    private func initUI() {
        
        if assets == nil {self.assets = photoAlbums.first! }
        let photoAlbumBtnFrame = CGRect(x: (ScreenWidth-150)/2, y: 20, width: 150, height: 44)
        photoAlbumBtn = UIButton(frame: photoAlbumBtnFrame)
        photoAlbumBtn.setTitle(assets.keys.first, for: .normal)
        photoAlbumBtn.setTitleColor(UIColor.white, for: .normal)
        
        if arrowUpName != nil && arrowDownName != nil {
            self.photoAlbumBtn.setImage(UIImage(named: self.arrowUpName!), for: .normal)
            self.photoAlbumBtn.setImage(UIImage(named: self.arrowDownName!), for: .selected)
        }else{
            photoAlbumBtn.setTitle("\(assets.keys.first!) ▲", for: .normal)
            photoAlbumBtn.setTitle("\(assets.keys.first!) ▼", for: .selected)
            
        }
        
        photoAlbumBtn.addTarget(self, action: #selector(YVImagePickerController.didphotoAlbumBtn), for: .touchUpInside)
        photoAlbumBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 120, bottom: 0, right: 0)
        photoAlbumBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        topView.addSubview(photoAlbumBtn)
        
        let layout = UICollectionViewFlowLayout()
        let yvitemSize = CGSize(width: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns), height: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns))
        layout.itemSize = yvitemSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let imageCollVFrame = CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight-64)
        
        imageCollV = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        imageCollV.backgroundColor = UIColor.white
        
        imageCollV.delegate = self
        imageCollV.dataSource = self
        self.view.addSubview(imageCollV)
        imageCollV.register(YVImagePickerCell.self, forCellWithReuseIdentifier: "YVImagePickerCell")
        if yvIsMultiselect == true {
            //多选
            let nextBtnFrame = CGRect(x: ScreenWidth-20-70, y: 20, width: 70, height: 44)
            nextBtn = UIButton(frame: nextBtnFrame)
            nextBtn.setTitle("下一步", for: .normal)
            nextBtn.addTarget(self, action: #selector(YVImagePickerController.didnextBtn), for: .touchUpInside)
            topView.addSubview(nextBtn)
        }else{  print("单选") }
    }
    func createYVTopView() {
        let topFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 64)
        topView = UIView(frame: topFrame)
        topView.backgroundColor = topViewColor
        let leftFrame = CGRect(x: 10, y: 20, width: 44, height: 44)
        let leftBtn = UIButton(frame: leftFrame)
        leftBtn.addTarget(self, action: #selector(YVImagePickerController.didleftBtn), for: .touchUpInside)
        leftBtn.setTitle("取消", for: .normal)
        self.view.addSubview(topView)
        topView.addSubview(leftBtn)
    }
    func didleftBtn()  {
        if self.delegate != nil {
            self.delegate.yvimagePickerControllerDidCancel(self)
        }
    }
    func didphotoAlbumBtn() {
        if photoAlbumBtn.isSelected == true {
            removeTab()
        }else{
            addTab()
        }
    }
    func removeTab() {
        photoAlbumBtn.isSelected = false
        photoAlbumTab.removeFromSuperview()
    }
    func addTab() {
        let photoAlbumTabFrame = CGRect(x: 0, y: 64, width: ScreenWidth, height: ScreenHeight-64)
        photoAlbumTab = UITableView(frame: photoAlbumTabFrame, style: .plain)
        photoAlbumTab.dataSource = self
        photoAlbumTab.delegate = self
        photoAlbumTab.rowHeight = 60
        photoAlbumTab.tableFooterView = UIView()
        self.view.addSubview(photoAlbumTab)
        photoAlbumBtn.isSelected = true
    }
    func didnextBtn() {
        if selectedAssets.count != 0 {
            self.phassetsToImages(selectedAssets)
        }else{
            self.addReminder(title: "请选择照片")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.first!.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImagePickerCell", for: indexPath) as! YVImagePickerCell
        let asset = assets.first!.value[indexPath.row]
        cell.tag = Int(
            photoManage.requestImage(for: asset, targetSize: pickerPhotoSize, contentMode: .aspectFit, options: photoOption, resultHandler: { (result, info) in
                if result != nil {
                    if (info?["PHImageResultIsDegradedKey"] as! Bool) == true {
                        
                    }else{
                        cell.imageV.image = result!
                    }
                }
            })
        )
        if yvIsMultiselect == true {
            cell.closeBtn.isHidden = false
            cell.timeLab.isHidden = true
            if self.index(ofSelect: asset) != nil {
                cell.closeBtn.isSelected = true
            }else{
                cell.closeBtn.isSelected = false
            }
        }else{
            cell.closeBtn.isHidden = true
            cell.timeLab.isHidden = false
            cell.timeLab.text =  Float(asset.duration).getMMSSFromSS()
        }
        switch yvmediaType {
        case .video:
            cell.timeLab.isHidden = false
        case .image:
            cell.timeLab.isHidden = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if yvIsMultiselect == true {
            let cell =  collectionView.cellForItem(at: indexPath) as! YVImagePickerCell
            if cell.closeBtn.isSelected == true {
                cell.closeBtn.isSelected = false
                remove(formSelect: assets.first!.value[indexPath.row])
            }else{
                if selectedAssets.count+1 > yvmaxSelected  {
                    self.addReminder(title: "不能超过\(yvmaxSelected)张")
                    return
                }
                cell.closeBtn.isSelected = true
                selectedAssets.append(assets.first!.value[indexPath.row])
            }
        }else{
            
            switch yvmediaType {
            case .video:
                //判断是否超过5分钟 300s
                if assets.first!.value[indexPath.row].duration > 300 {
                    self.addReminder(title: "超过5分钟，不能导入")
                    return
                }
                photoManage.requestAVAsset(forVideo: assets.first!.value[indexPath.row], options: nil) {[weak self] (asset, assmix, info) in
                    if asset as? AVURLAsset != nil {
                        let urlasset = asset as! AVURLAsset
                        DispatchQueue.main.async {
                            self?.delegate.yvimagePickerController(self!, didFinishPickingMediaWithInfo: ["videodata": urlasset.url])
                        }
                    }else{
                        self?.exportAvailableVideo(asset: asset!, finished: { (videourl) in
                            DispatchQueue.main.async {
                                self?.delegate.yvimagePickerController(self!, didFinishPickingMediaWithInfo: ["videodata": videourl])
                            }
                        })
                    }
                }
            case .image:
                photoManage.requestImageData(for: assets.first!.value[indexPath.row], options: nil, resultHandler: { [weak self] (imagedata, str, orientation, hashable) in
                    DispatchQueue.main.async {
                        self?.delegate.yvimagePickerController(self!, didFinishPickingMediaWithInfo: ["imagedata": UIImage.init(data: imagedata!) as Any])
                    }
                })
            }
        }
    }
    
    func index(ofSelect alasset: PHAsset) -> Int? {
        return selectedAssets.index(of: alasset)
    }
    func remove(formSelect alasset: PHAsset) {
        if let index = index(ofSelect: alasset) {
            selectedAssets.remove(at: index)
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAlbums.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier:  "YVImagePickerController")
        cell.textLabel?.text = photoAlbums[indexPath.row].keys.first
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.assets = photoAlbums[indexPath.row]
        self.photoAlbumBtn.setTitle((photoAlbums[indexPath.row].keys.first)!, for: .normal)
        self.imageCollV.reloadData()
        removeTab()
    }
    func exportAvailableVideo(asset: AVAsset,finished: @escaping ((_ url: URL)->())) {
        let exporterSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporterSession?.outputFileType = AVFileTypeQuickTimeMovie
        exporterSession?.outputURL = URL(fileURLWithPath: self.yvOutputPath)
        if FileManager.default.fileExists(atPath: self.yvOutputPath) {
            do {
                try FileManager.default.removeItem(atPath: self.yvOutputPath)
                print("Downloaded dir creat success")
            }catch{
                print("failed to create downloaded dir")
            }
        }
        exporterSession?.exportAsynchronously(completionHandler: { () -> Void in
            switch exporterSession!.status {
            case .unknown:
                print("unknow")
            case .cancelled:
                print("cancelled")
            case .failed:
                print("failed")
            case .waiting:
                print("waiting")
            case .exporting:
                print("exporting")
            case .completed:
                print("completed")
                finished(URL(fileURLWithPath: self.yvOutputPath))
            }
        })
    }
    func addReminder(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        let NoBtn = UIAlertAction(title: "取消", style: .cancel) { (action) in}
        alert.addAction(NoBtn)
        present(alert, animated: true, completion: nil)
        
    }
    func toAuthorization() {
        let alert = UIAlertController(title: "无照片权限", message: "请在设置中授予照片访问权限", preferredStyle: .alert)
        let YesBtn = UIAlertAction(title: "确定", style: .destructive) { (action) in
            if URL(string: UIApplicationOpenSettingsURLString) != nil {
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }
        }
        let NoBtn = UIAlertAction(title: "取消", style: .cancel) { (action) in}
        alert.addAction(YesBtn)
        alert.addAction(NoBtn)
        present(alert, animated: true, completion: nil)
    }
    
    func phassetsToImages(_ phassets: Array<PHAsset>) {
        
        SVProgressHUD.show()
        var yvimages = Array<UIImage>()
        
        for item in phassets{
            
            photoManage.requestImageData(for: item, options: nil, resultHandler: { [weak self] (imagedata, str, orientation, hashable) in
                let image = UIImage.init(data: imagedata!)
                yvimages.append((image?.fixOrientation())!)
                if yvimages.count == phassets.count {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        if self?.delegate != nil {
                            self?.delegate.yvimagePickerController(self!, didFinishPickingMediaWithInfo: ["imagedatas": yvimages])
                        }                    }
                    return
                    
                }
            })
        }
    }
}
extension Float{
    //秒-> xx:xx
    func getMMSSFromSS() -> String {
        let fl_minute: Float =  self/60
        let fl_second: Float = self.truncatingRemainder(dividingBy: 60)
        let str_second =  String(format: "%02d", Int(fl_second))
        let format_time = "\(Int(fl_minute)):\(str_second)"
        return format_time
    }
}
