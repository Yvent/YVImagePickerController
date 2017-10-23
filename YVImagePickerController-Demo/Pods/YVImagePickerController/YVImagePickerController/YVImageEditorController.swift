

import UIKit
import AVFoundation
import Photos

open class YVImageEditorController: UIViewController ,YVNavigationViewDelegate, UICollectionViewDelegate,UICollectionViewDataSource{
    
    lazy var pickerPhotoSize:CGSize = {
        
        let sreenBounds = UIScreen.main.bounds
        let screenWidth = sreenBounds.width > sreenBounds.height ? sreenBounds.height : sreenBounds.width
        let width = (screenWidth - CGFloat(2) * (CGFloat(2) - 1)) / CGFloat(3)
        return CGSize(width: width, height: width)
        
        
    }()
    
    ///列数
   open var yvcolumns = 4
   public var navView: YVNavigationView!
   open var tipsLabel: UILabel!
    
   var imageCollV: UICollectionView!
    
   var addPhotoBtn: UIButton!
   open var phassets = Array<PHAsset>()
    
   var imageArr: Array<UIImage> = Array<UIImage>()
    
   open  var finished: ((_ url: URL, _ assets: Array<PHAsset>)->())!
    
   open  var cellsize: CGSize!
    
    private var photoManage = PHImageManager()
    private let photoOption = PHImageRequestOptions()
    private let photoCreationDate = "creationDate"

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        initUI()
    }
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageCollV.reloadData()
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    private func initUI()  {
        self.photoOption.resizeMode   = .fast
        self.photoOption.deliveryMode = .opportunistic
        
        navView = YVNavigationView(yv_bc: YVNavColor, any: self, title: "编辑幻灯片", lefttitle: "取消", leftnamed: nil, righttitle:  "完成", rightnamed: nil)
        
        tipsLabel = UILabel(frame: CGRect(x: 0, y: yvRealHeight(), width: ScreenWidth, height: 27))
        tipsLabel.text = "拖拽图片改变幻灯片播放顺序"
        tipsLabel.textColor = YVNavColor
        tipsLabel.font = UIFont.systemFont(ofSize: 12)
        tipsLabel.textAlignment = .center
        self.view.addSubview(tipsLabel)

        let layout = UICollectionViewFlowLayout()
        let yvitemSize = CGSize(width: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns), height: (ScreenWidth-CGFloat(yvcolumns-1))/CGFloat(yvcolumns))
        layout.itemSize = yvitemSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 0
        let imageCollVFrame = CGRect(x: 0, y: yvRealHeight()+27, width: ScreenWidth, height: ScreenHeight-yvRealHeight())
        
        imageCollV = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        imageCollV.backgroundColor = UIColor.white
        
        imageCollV.delegate = self
        imageCollV.dataSource = self
        self.view.addSubview(imageCollV)
        imageCollV.register(YVImageEditorCollVCell.self, forCellWithReuseIdentifier: "YVImageEditorCollVCell")
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(YVImageEditorController.longPress(_:)))
        imageCollV.addGestureRecognizer(longPress)
        addPhotoBtn = UIButton(frame: CGRect(x: 0, y: ScreenHeight-60, width: ScreenWidth, height: 60))
        addPhotoBtn.setTitle("+ 添加照片", for: .normal)
        addPhotoBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        addPhotoBtn.backgroundColor = YVNavColor
        addPhotoBtn.addTarget(self, action: #selector(YVImageEditorController.doaddPhotoBtn), for: .touchUpInside)
        self.view.addSubview(addPhotoBtn)

    }
    func compressImage(_ image: UIImage) -> Data {
        let resize = resizeImage(image, toSize: CGSize(width: image.size.width, height: image.size.height))
        return UIImageJPEGRepresentation(resize, 0.5)!
    }
    func resizeImage(_ image: UIImage, toSize: CGSize) -> UIImage {
        let size = CGSize(width: toSize.width, height: toSize.height)
        UIGraphicsBeginImageContext(size)
        
        let path = UIBezierPath(rect: CGRect(origin: CGPoint.zero, size: size))
        
        // 添加裁切路径 - 后续的绘制，都会被此路径裁切掉
        path.addClip()
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resize = UIGraphicsGetImageFromCurrentImageContext()
    
        UIGraphicsEndImageContext()
        return resize!
    }
    @objc func doaddPhotoBtn() {
        
        let imageP = YVImagePickerController()
        imageP.yvIsMultiselect = true
        imageP.yvmediaType = .image
        imageP.selectedAssets = phassets
        imageP.yvdelegate = self
        imageP.isEditImages = true
        
        self.present(imageP, animated: true, completion: nil)
        
    }
    func modelTip() {
        let alert = UIAlertController(title: "是否放弃对幻灯片的编辑？", message: "", preferredStyle: .alert)
        let YesBtn = UIAlertAction(title: "确定", style: .destructive) { (action) in
             self.dismiss(animated: true, completion: nil)
        }
        let NoBtn = UIAlertAction(title: "取消", style: .cancel) { (action) in}
        alert.addAction(YesBtn)
        alert.addAction(NoBtn)
        present(alert, animated: true, completion: nil)
    }

    
    public func yvdidleftitem() {modelTip()}
    
    public func yvdidrightitem() {
        if phassets.count == 0 {
             self.dismiss(animated: true, completion: nil)
        }else{
            
           YVLoadinger.shared.show()
            var imageArrCopt = [UIImage]()
              var imageArrCopy = [UIImage]()
            
            for item in phassets{
                
                photoManage.requestImageData(for: item, options: nil, resultHandler: { [weak self] (imagedata, str, orientation, hashable) in
                  
                    let image = UIImage.init(data: imagedata!)
                    imageArrCopt.append((image?.fixOrientation1())!)
                    
                    if imageArrCopt.count == self?.phassets.count {

                        for item in imageArrCopt {
                            
                            
                            
                            let rect = self?.cellSizeToImageRect(cellsize: (self?.cellsize)!, zimage: item)
                            
                            
                                imageArrCopy.append((self?.resizeImage(item.yv_cropImage(rect: rect!), toSize: CGSize(width: (self?.cellsize.width)!*2, height: (self?.cellsize.height)!*2)))!)
                            
                            
                                if imageArrCopy.count == imageArrCopt.count {
                                    
                                    
                                    let videoSettings = CXEImageToVideoAsync.videoSettings(codec: AVVideoCodecH264, width: Int(((self?.cellsize.width)!*2)), height: Int(((self?.cellsize.height)!*2)))
                                    let async = CXEImageToVideoAsync(videoSettings: videoSettings)
                                    
                                    async.createMovieFrom(images: imageArrCopy) { [weak self] (fileURL) in
                                        
                                        DispatchQueue.main.async {
                                            self?.finished(fileURL,(self?.phassets)!)
//                                           YVLoadinger.dismiss()
                                            YVLoadinger.shared.dismiss()
                                            self?.view.isUserInteractionEnabled = true
                                            self?.dismiss(animated: true, completion: nil)
                                        }
                                        
                                        
                                    }
                                    
                                    
                                    
                                }
                        }
                        
                        
                    
                    }
                })
            }
            
        }
        
    }
    @objc func longPress(_ longPress: UILongPressGestureRecognizer)  {
        
        let point = longPress.location(in: self.imageCollV)
        
        if longPress.state == .began {
            let indexPath = self.imageCollV.indexPathForItem(at: point)
            self.imageCollV.beginInteractiveMovementForItem(at: indexPath!)
            
        }else if longPress.state == .changed {
        
         self.imageCollV.updateInteractiveMovementTargetPosition(point)
        }else if longPress.state == .ended {
        
        self.imageCollV.endInteractiveMovement()
        }else{
        
        self.imageCollV.cancelInteractiveMovement()
        }
        
      
    }
    
    
    func cellSizeToImageRect(cellsize: CGSize,zimage: UIImage) -> CGRect {
        let rate: Bool = cellsize.width/cellsize.height >= zimage.size.width/zimage.size.height
        //rate为true取裁剪框宽度，否则取高度
        if rate == true {
            let iW = zimage.size.width
            let iH = cellsize.height*(zimage.size.width/cellsize.width)
            return  CGRect(x: 0, y:(zimage.size.height-iH)/2, width: iW, height: iH)
            //             return  CGRect(x: 0, y:0, width: iW, height: iH)
        }else{
            let iW = cellsize.width*(zimage.size.height/cellsize.height)
            let iH = zimage.size.height
            return  CGRect(x: (zimage.size.width-iW)/2, y:0, width: iW, height: iH)
            //            return  CGRect(x: 0, y:0, width: iW, height: iH)
        }
    }
    
   open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phassets.count
    }
    
   open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVImageEditorCollVCell", for: indexPath) as! YVImageEditorCollVCell
        cell.didclickcloseBtn = {
            self.phassets.remove(at: indexPath.row)
            self.imageArr.removeAll()
            collectionView.reloadData()
        }
        let asset = phassets[indexPath.row]
        cell.tag = Int(
        
            photoManage.requestImage(for: asset, targetSize: pickerPhotoSize, contentMode: .aspectFit, options: photoOption, resultHandler: { [weak self](result, info) in
            
                if result != nil {
                    
                    if (info?["PHImageResultIsDegradedKey"] as! Bool) == true {
                        // Do something with the FULL SIZED image
                        print("\(result)")
                    
                    }else{
                              print("\(result)")
                        cell.imageV.image = result!
                        self?.imageArr.append(result!)
                        
                    }
                    
                    
                    
                }
                
             
            })
        )
        return cell
    }
   open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let imageAsset = phassets[sourceIndexPath.item]
        phassets.remove(at: sourceIndexPath.item)
        phassets.insert(imageAsset, at: destinationIndexPath.item)
    }


}
extension YVImageEditorController:  YVImagePickerControllerDelegate{
    
   open func yvimagePickerController(_ picker: YVImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if info["imagedatas"] != nil{
            let phassets = info["imagedatas"] as! Array<PHAsset>
            self.phassets = phassets
            self.imageCollV.reloadData()
            }else{
            print("未知类型")
            }
    
     }
  open  func yvimagePickerControllerDidCancel(_ picker: YVImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

