
//
//  Created by 周逸文 on 2017/10/11.
//  Copyright © 2017年 YV. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

public protocol YVImagePickerControllerDelegate: class {
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

open class YVImagePickerController: UIViewController ,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDelegate,UITableViewDataSource{
    
    
    //当导出的视频为AVURLAsset不需要，输出视频URL
    open  var outputVideoUrl: URL! = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last! + "/YVPicker_temp.mp4")
    //多选时最大张数
    open var yvmaxSelected = 10
    //列数
    open var yvcolumns = 4
    //导航栏背景色
    open var topViewColor: UIColor = UIColor(red: 88/255.0, green: 197/255.0, blue: 141/255.0, alpha: 1)
    //过滤相册时上下icon
    open  var arrowUpName: String?
    open  var arrowDownName: String?
    //媒体类型：照片或视频
    open  var yvmediaType: yvMediaType = .image
    //是否多选，默认单选
    open  var yvIsMultiselect: Bool! = false
    //是否编辑,默认不编辑（直接输出资源）
    open  var isEditContents: Bool = false
    //多选按钮—normal
    open var selectedBtn_nimage: UIImage?
    //多选按钮—select
    open var selectedBtn_simage: UIImage?
    
    open  var topView: UIView!
    weak open var yvdelegate: YVImagePickerControllerDelegate!
    //全部相册的数组
    private(set) var photoAlbums    = [[String: PHFetchResult<PHAsset>]]()
    
    var pickerPhotoSize: CGSize!
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
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        createYVTopView()
        photoAuthorization()
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override open func viewWillAppear(_ animated: Bool) {
        if  self.yvPHstatus == yvPHAuthorizationStatus.yvdenied {
            toAuthorization()
        }
    }
    override open func didReceiveMemoryWarning() {
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
        self.photoOption.isSynchronous = false
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
        let photoAlbumBtnFrame = CGRect(x: (ScreenWidth-150)/2, y: yvRealHeight()-44, width: 150, height: 44)
        photoAlbumBtn = UIButton(frame: photoAlbumBtnFrame)
        photoAlbumBtn.setTitle(assets.keys.first, for: .normal)
        photoAlbumBtn.setTitleColor(UIColor.white, for: .normal)
        if arrowUpName != nil && arrowDownName != nil {
            self.photoAlbumBtn.setImage(UIImage(named: self.arrowUpName!), for: .normal)
            self.photoAlbumBtn.setImage(UIImage(named: self.arrowDownName!), for: .selected)
        }else{
            let bundle =  Bundle(for: YVImagePickerController.self)
            let path = bundle.path(forResource: "YVImagePickerController", ofType: "bundle")
            let imageBundle =  Bundle(path: path!)
            let nolImage = UIImage(contentsOfFile: (imageBundle?.path(forResource: "arrow_up", ofType: "png"))!)
            let solImage = UIImage(contentsOfFile: (imageBundle?.path(forResource: "arrow_down", ofType: "png"))!)
            
            photoAlbumBtn.setImage(nolImage, for: .normal)
            photoAlbumBtn.setImage(solImage, for: .selected)
            photoAlbumBtn.setTitle("\(assets.keys.first!)", for: .normal)
            photoAlbumBtn.setTitle("\(assets.keys.first!)", for: .selected)
        }
        photoAlbumBtn.addTarget(self, action: #selector(YVImagePickerController.didphotoAlbumBtn), for: .touchUpInside)
        photoAlbumBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 120, bottom: 0, right: 0)
        photoAlbumBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        topView.addSubview(photoAlbumBtn)
        pickerPhotoSize = CGSize(width: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns), height: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns))
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = pickerPhotoSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let imageCollVFrame = CGRect(x: 0, y: yvRealHeight(), width: ScreenWidth, height: ScreenHeight-yvRealHeight())
        
        imageCollV = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        imageCollV.backgroundColor = UIColor.white
        imageCollV.delegate = self
        imageCollV.dataSource = self
        self.view.addSubview(imageCollV)
        imageCollV.register(YVImagePickerCell.self, forCellWithReuseIdentifier: "YVImagePickerCell")
        if yvIsMultiselect == true {
            //多选
            let nextBtnFrame = CGRect(x: ScreenWidth-20-70, y: yvRealHeight()-44, width: 70, height: 44)
            nextBtn = UIButton(frame: nextBtnFrame)
            nextBtn.setTitle("下一步", for: .normal)
            nextBtn.addTarget(self, action: #selector(YVImagePickerController.didnextBtn), for: .touchUpInside)
            topView.addSubview(nextBtn)
        }else{  print("单选") }
    }
    func createYVTopView() {
        let topFrame = CGRect(x: 0, y: 0, width: ScreenWidth, height: yvRealHeight())
        topView = UIView(frame: topFrame)
        topView.backgroundColor = topViewColor
        let leftFrame = CGRect(x: 10, y: yvRealHeight()-44, width: 44, height: 44)
        let leftBtn = UIButton(frame: leftFrame)
        leftBtn.addTarget(self, action: #selector(YVImagePickerController.didleftBtn), for: .touchUpInside)
        leftBtn.setTitle("取消", for: .normal)
        self.view.addSubview(topView)
        topView.addSubview(leftBtn)
    }
    @objc func didleftBtn()  {
        if self.yvdelegate != nil {
            self.yvdelegate.yvimagePickerControllerDidCancel(self)
        }
    }
    @objc func didphotoAlbumBtn() {
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
        let photoAlbumTabFrame = CGRect(x: 0, y: yvRealHeight(), width: ScreenWidth, height: ScreenHeight-yvRealHeight())
        photoAlbumTab = UITableView(frame: photoAlbumTabFrame, style: .plain)
        photoAlbumTab.dataSource = self
        photoAlbumTab.delegate = self
        photoAlbumTab.rowHeight = 60
        photoAlbumTab.tableFooterView = UIView()
        self.view.addSubview(photoAlbumTab)
        photoAlbumBtn.isSelected = true
    }
    //多选照片是下一步
    @objc func didnextBtn() {
        
        if yvmediaType == .video {
            if selectedAssets.count != 0 {
                self.phassetsToVideoUrls(selectedAssets)
            }else{
                self.addReminder(title: "请选择视频")
            }
        }else{
            if selectedAssets.count != 0 {
                self.phassetsToImageUrls(selectedAssets)
            }else{
                self.addReminder(title: "请选择照片")
            }
            
        }
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.first!.value.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImagePickerCell", for: indexPath) as! YVImagePickerCell
        
        let asset = assets.first!.value[indexPath.row]
        cell.tag = Int(
            photoManage.requestImage(for: asset, targetSize: pickerPhotoSize, contentMode: .aspectFit, options: photoOption, resultHandler: { (result, info) in
                if result != nil {
                    if (info?["PHImageResultIsDegradedKey"] as! Bool) == true {
                        // Do something with the FULL SIZED image
                        //返回高清图片
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
        if selectedBtn_nimage != nil{
            cell.closeBtn.setImage(selectedBtn_nimage, for: .normal)
        }
        if selectedBtn_simage != nil{
            cell.closeBtn.setImage(selectedBtn_simage, for: .selected)
        }
        return cell
    }
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
                self.requestAsset(phasset: assets.first!.value[indexPath.row], finished: { (asset) in
                    if let urlasset = asset as? AVURLAsset {
                        DispatchQueue.main.async {
                            self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["videodata": urlasset.url])
                        }
                    }else{
                        YVSplitVideoManager.shared.yvSplitVideo(asset, videoTimeRange: nil, outUrl: (self.outputVideoUrl)!, finished: {
                            DispatchQueue.main.async {
                                self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["videodata": self.outputVideoUrl! as Any])
                            }
                        })
                    }
                    
                })
            case .image:
                self.requestData(phasset: assets.first!.value[indexPath.row], finished: { (imageData) in
                    self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["imagedata": UIImage.init(data: imageData) as Any])
                    
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
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoAlbums.count
    }
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  UITableViewCell(style: .subtitle, reuseIdentifier:  "YVImagePickerController")
        cell.textLabel?.text = photoAlbums[indexPath.row].keys.first
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.assets = photoAlbums[indexPath.row]
        self.photoAlbumBtn.setTitle((photoAlbums[indexPath.row].keys.first)!, for: .normal)
        self.imageCollV.reloadData()
        removeTab()
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
    //直接返回 UIImage
    func phassetsToImages(_ phassets: Array<PHAsset>) {
        YVLoadinger.shared.show()
        self.view.isUserInteractionEnabled = false
        var yvimages = Array<UIImage>()
        let group = DispatchGroup()
        for item in phassets{
            group.enter()
            self.requestData(phasset: item, finished: { (imageData) in
                DispatchQueue.main.async {
                    let image = UIImage.init(data: imageData)
                    yvimages.append((image?.fixOrientation())!)
                }
                group.leave()
            })
        }
        
        group.notify(queue: DispatchQueue.main) {
            YVLoadinger.shared.dismiss()
            self.view.isUserInteractionEnabled = true
            self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["imagedatas": yvimages])
        }
    }
    
    func phassetsToImageUrls(_ phassets: Array<PHAsset>)  {
        if isEditContents == true {
            self.preToEditor(selectedAssets)
        }else{
            self.phassetsToImages(selectedAssets)
        }
    }
    
    
    func phassetsToVideoUrls(_ phassets: Array<PHAsset>)  {
        YVLoadinger.shared.show()
        self.view.isUserInteractionEnabled = false
        var yvvideos = Array<URL>()
        let group = DispatchGroup()
        for item in phassets{
            group.enter()
            if isEditContents == true {
                self.requestAsset(phasset: item, finished: { (asset) in
                    if let urlasset = asset as? AVURLAsset  {
                        DispatchQueue.main.async {
                            yvvideos.append(urlasset.url)
                        }
                    }
                    group.leave()
                })
            }else{
                self.requestExport(phasset: item, finished: { (states, url) in
                    if states == .completed  {
                        if let videourl = url{
                            DispatchQueue.main.async {
                                yvvideos.append(videourl)
                            }
                        }
                        group.leave()
                    }
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            YVLoadinger.shared.dismiss()
            print("\(yvvideos.count)")
            self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["videodatas": yvvideos])
        }
    }
    
    /// 导出imagedata
    func requestData( phasset: PHAsset, finished: @escaping ((_ imagedata: Data)->())) {
        photoManage.requestImageData(for: phasset, options: nil) { [weak self] (imagedata, str, orientation, info) in
            if imagedata == nil {
                self?.addReminder(title: "iCloud云相册的照片，需要您先下载到相册，再重试哦")
                return
            }
            finished(imagedata!)
        }
    }
    /// 导出视频，一般用于持久性储存
    func requestExport( phasset: PHAsset, finished: @escaping ((_ states: AVAssetExportSessionStatus?, _ outputURL: URL?)->()))  {
        ///AVAssetExportPresetHighestQuality 高清
        photoManage.requestExportSession(forVideo: phasset, options: nil, exportPreset: AVAssetExportPresetHighestQuality) { (exportSession, info) in
            exportSession?.outputURL = URL(fileURLWithPath: contentOfDocuments()+"\(initId()).mp4")
            exportSession?.outputFileType = AVFileTypeQuickTimeMovie
            exportSession?.exportAsynchronously(completionHandler: {
                finished(exportSession?.status, exportSession?.outputURL)
            })
        }
    }
    /// 请求获得 AVAsset，一般用于可编辑
    func requestAsset( phasset: PHAsset, finished: @escaping ((_ asset: AVAsset)->()))  {
        photoManage.requestAVAsset(forVideo: phasset, options: nil) { [weak self] (asset, amix, info) in
            if asset == nil {
                self?.addReminder(title: "iCloud云相册的视频，需要您先下载到相册，再重试哦")
                return
            }
            finished(asset!)
        }
    }
    //返回 PHAsset
    func preToEditor(_ phassets: Array<PHAsset>)  {
        if self.yvdelegate != nil {
            self.yvdelegate.yvimagePickerController(self, didFinishPickingMediaWithInfo: ["imagedatas": phassets])
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
