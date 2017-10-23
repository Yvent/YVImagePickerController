
import UIKit
import AVFoundation
import Photos

open class YVVideoEditorViewController: UIViewController,YVNavigationViewDelegate ,UICollectionViewDelegate,UICollectionViewDataSource{

    
    //输入视频URL
    open var inputVideoUrl: URL!
    //输出视频URL
    open var outputVideoUrl: URL!
    //背景色
    open var contentColor: UIColor = UIColor(red: 35/255, green: 31/255, blue: 32/255, alpha: 1)
    //完成回调
    open   var finished: ((_ url: URL)->())!
    //照片编辑器cell的宽
    var cellW: CGFloat = 30

    var yvvideoAsset: AVURLAsset!
    var videoPlayer: AVPlayer!
    var videoplayerItem: AVPlayerItem!
    var videoplayerlayer: AVPlayerLayer!
    
    
    public var navView: YVNavigationView!
    var imageCV: UICollectionView!
    var videoEditorView:UIView!
    var leftBtn: UIImageView!
    var rightBtn: UIImageView!
    var tipslabel: UILabel!
    var instructions: UILabel!
    
    
    var videoTimecopy: Int!
    var startt: CMTimeValue! = 0
    var starttCopy: CMTimeValue! = 0
    var continuoust: CMTimeValue! = 0
    var previousPoint: CGPoint!
    var startPoint: CGPoint!
    var startLocation: CGPoint!
    var editorW: CGFloat!
    var isobser: Bool! = true
    
    var playerobser: Any!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = contentColor
        navView = YVNavigationView(yv_bc: YVNavColor, any: self, title: "视频编辑", lefttitle: "取消", leftnamed: nil, righttitle:  "完成", rightnamed: nil)
        initConfig()
    }
    
    deinit {
        print("释放")
        self.videoPlayer.removeTimeObserver(playerobser)
        playerobser = nil
    }
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initConfig() {
        
        yvvideoAsset = AVURLAsset(url: self.inputVideoUrl)
        self.videoTimecopy = Int(yvvideoAsset.duration.value)/Int(yvvideoAsset.duration.timescale)
        if videoTimecopy > 10 {
            continuoust = Int64(10*yvvideoAsset.duration.timescale)
        }else{
            continuoust = Int64(Int32(videoTimecopy)*yvvideoAsset.duration.timescale)
        }
        starttCopy = continuoust+startt
        self.initvideoPlayer()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoPlayer.play()
    }
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func initvideoPlayer(){
        
        self.videoplayerItem = AVPlayerItem(url:  self.inputVideoUrl)
        self.videoPlayer = AVPlayer(playerItem: self.videoplayerItem)
        self.videoplayerlayer = AVPlayerLayer(player: self.videoPlayer)
        self.videoplayerlayer.backgroundColor = UIColor.black.cgColor
        self.view.layer.addSublayer(self.videoplayerlayer)
        self.videoplayerlayer.frame = CGRect(x: ScreenWidth*0.2, y: ScreenHeight*0.1*0.5+64, width: ScreenWidth*0.6, height: ScreenHeight*0.6)
        playerobser =  self.videoPlayer.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 10), queue: DispatchQueue.main) {[weak self] (time) in
            let endtimes = CMTimeGetSeconds(CMTimeMake(((self?.startt)!+(self?.continuoust)!), (self?.yvvideoAsset.duration.timescale)!))
            let endtimesc = CMTimeGetSeconds(time)
            let str_endtimes =  String(format: "%.1f", endtimes)
            let str_endtimesc =  String(format: "%.1f", endtimesc)
            if self?.isobser == true {
                if str_endtimes == str_endtimesc{
                    self?.videoPlayer.pause()
                    self?.videoPlayer.seek(to: CMTimeMake((self?.startt)!, (self?.yvvideoAsset.duration.timescale)!))
                    self?.videoPlayer.play()
                }
            }
        }
        initUI()
    }
    func initUI() {
        
        let layout = UICollectionViewFlowLayout()
        let yvitemSize = CGSize(width: cellW, height:  50)
        layout.itemSize = yvitemSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 18)
        let imageCollVFrame = CGRect(x: 0, y: ScreenHeight*0.1*0.2+64+ScreenHeight*0.7, width: ScreenWidth, height: 50)
        
        imageCV = UICollectionView(frame: imageCollVFrame, collectionViewLayout: layout)
        imageCV.backgroundColor = contentColor
        imageCV.delegate = self
        imageCV.dataSource = self
        imageCV.contentInset = UIEdgeInsets(top: 0, left: (ScreenWidth-cellW*10)/2, bottom: 0, right: (ScreenWidth-cellW*10)/2)
        
        imageCV.register(YVSplitVideoCell.self, forCellWithReuseIdentifier: "YVVideoEditorViewController")
        imageCV.decelerationRate = UIScrollViewDecelerationRateFast
        leftBtn = UIImageView(image: UIImage(named: "handle_L"))
        leftBtn.backgroundColor = UIColor.white
        let panGestureleft = UIPanGestureRecognizer(target: self, action: #selector(YVVideoEditorViewController.handlePanGestureleft(_:)))
        leftBtn.addGestureRecognizer(panGestureleft)
        leftBtn.isUserInteractionEnabled = true
        rightBtn = UIImageView(image: UIImage(named: "handle_R"))
        rightBtn.backgroundColor = UIColor.white
        let panGestureright = UIPanGestureRecognizer(target: self, action: #selector(YVVideoEditorViewController.handlePanGestureright(_:)))
        rightBtn.addGestureRecognizer(panGestureright)
        rightBtn.isUserInteractionEnabled = true
        let videoEditorViewFrameW = videoTimecopy > 10 ? cellW*10 : cellW*CGFloat(videoTimecopy)
        let videoEditorViewFrame = CGRect(x: imageCV.contentInset.left, y: imageCV.frame.origin.y, width: videoEditorViewFrameW, height: 50)
        videoEditorView = UIView(frame: videoEditorViewFrame)
        videoEditorView.isUserInteractionEnabled = false
        videoEditorView.backgroundColor = UIColor.clear
        videoEditorView.layer.borderWidth = 2
        videoEditorView.layer.borderColor = UIColor.white.cgColor
        editorW = videoEditorView.frame.width
        let timeStr =  (Float(continuoust)/Float(self.yvvideoAsset.duration.value)*Float(videoTimecopy)).getMMSSFromSS()
        let tipslabelstr = videoTimecopy > 10 ? "00:10" : timeStr
        tipslabel = UILabel(frame: CGRect(x: imageCollVFrame.origin.x, y: imageCollVFrame.origin.y-50, width: imageCollVFrame.width, height: 40))
        tipslabel.textAlignment = .center
        tipslabel.text = tipslabelstr
        tipslabel.textColor = UIColor.gray
        instructions = UILabel(frame: CGRect(x: imageCollVFrame.origin.x, y: imageCollVFrame.maxY+10, width: imageCollVFrame.width, height: 40))
        instructions.textAlignment = .center
        instructions.text = "最多时长10s"
        instructions.textColor = UIColor.gray
        self.view.addSubview(imageCV)
        self.view.addSubview(videoEditorView)
        self.view.addSubview(leftBtn)
        self.view.addSubview(rightBtn)
        self.view.addSubview(tipslabel)
        self.view.addSubview(instructions)
        leftBtn.frame = CGRect(x: videoEditorView.frame.origin.x, y: videoEditorView.frame.origin.y, width: 20, height: 50)
        rightBtn.frame = CGRect(x: videoEditorView.frame.maxX-20, y: videoEditorView.frame.origin.y, width: 20, height: 50)
       
    }
    
    func slidingleft()  {
        isobser = false
        if self.imageCV.contentSize.width != 0 {
            self.startt = Int64(CGFloat(((self.imageCV.contentOffset.x)+(self.videoEditorView.frame.origin.x))/(cellW*CGFloat(videoTimecopy)))*CGFloat((self.yvvideoAsset.duration.value)))
            self.videoPlayer.seek(to: CMTimeMake((self.startt)!, (self.yvvideoAsset.duration.timescale)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            
            self.continuoust = starttCopy - (self.startt)!
        }
    }
    func slidingright() {
        isobser = false
        if self.imageCV.contentSize.width != 0 {
            starttCopy = Int64(CGFloat(((self.imageCV.contentOffset.x)+((self.videoEditorView.frame.maxX)))/(cellW*CGFloat(videoTimecopy)))*CGFloat((self.yvvideoAsset.duration.value)))
            self.videoPlayer.seek(to:CMTimeMake(starttCopy, (self.yvvideoAsset.duration.timescale)), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            self.continuoust = starttCopy - (self.startt)!
        }
    }
    func slidingend()  {
        let timestr =  (Float(continuoust)/Float(self.yvvideoAsset.duration.value)*Float(videoTimecopy)).getMMSSFromSS()
        tipslabel.text = timestr
        isobser = true
        if self.imageCV.contentSize.width != 0 {
            self.startt = Int64(CGFloat(((self.imageCV.contentOffset.x)+(self.videoEditorView.frame.origin.x))/(self.imageCV.contentSize.width))*CGFloat((self.yvvideoAsset.duration.value)))
            self.videoPlayer.seek(to: CMTimeMake((self.startt)!, (self.yvvideoAsset.duration.timescale)))
            self.videoPlayer.play()
        }
    }
    
    func slidingstart()  {
        isobser = false
        self.videoPlayer.pause()
    }
    //左拖拽手势
    func handlePanGestureleft(_ sender: UIPanGestureRecognizer)  {
        let state = sender.state
        if state == .began {
            self.previousPoint = sender.location(in: self.view)
            startPoint = self.previousPoint
            self.slidingstart()
        }else if  state == .ended{
            self.previousPoint = sender.location(in: self.view)
            startPoint = self.previousPoint
            editorW = videoEditorView.frame.width
            self.slidingend()
        }else{
            let currentTouchPoint: CGPoint = sender.location(in: self.view)
            if videoEditorView.frame.origin.x+(currentTouchPoint.x-self.previousPoint.x) < imageCV.contentInset.left {
                videoEditorView.frame = CGRect(x: imageCV.contentInset.left, y: videoEditorView.frame.origin.y, width: videoEditorView.frame.maxX-imageCV.contentInset.left, height: videoEditorView.frame.size.height)
            }else  if videoEditorView.frame.origin.x+(currentTouchPoint.x-self.previousPoint.x) > videoEditorView.frame.maxX-cellW-20 {
                videoEditorView.frame = CGRect(x: videoEditorView.frame.maxX-cellW-20 , y: videoEditorView.frame.origin.y, width: videoEditorView.frame.maxX-(videoEditorView.frame.maxX-cellW-20), height: videoEditorView.frame.size.height)
                
            }
            else{
                videoEditorView.frame = CGRect(x: videoEditorView.frame.origin.x+(currentTouchPoint.x-self.previousPoint.x), y: videoEditorView.frame.origin.y, width: videoEditorView.frame.size.width-(currentTouchPoint.x-self.previousPoint.x), height: videoEditorView.frame.size.height)
            }
            leftBtn.frame = CGRect(x: videoEditorView.frame.origin.x, y: videoEditorView.frame.origin.y, width: 20, height: videoEditorView.frame.height)
            self.previousPoint = sender.location(in: self.view)
            self.slidingleft()
        }
    }
    //又拖拽手势
    func handlePanGestureright(_ sender: UIPanGestureRecognizer)  {
        let state = sender.state
        if state == .began {
            self.previousPoint = sender.location(in: self.view)
            startPoint = self.previousPoint
            self.slidingstart()
        }else if  state == .ended{
            self.previousPoint = sender.location(in: self.view)
            startPoint = self.previousPoint
            editorW = videoEditorView.frame.width
            self.slidingend()
        }else{
            let currentTouchPoint: CGPoint = sender.location(in: self.view)
            if videoEditorView.frame.maxX+(currentTouchPoint.x-self.previousPoint.x) > (ScreenWidth-imageCV.contentInset.left) {
                videoEditorView.frame = CGRect(x: videoEditorView.frame.origin.x, y: videoEditorView.frame.origin.y, width: ScreenWidth-imageCV.contentInset.left-videoEditorView.frame.origin.x, height: videoEditorView.frame.size.height)
                rightBtn.frame = CGRect(x: videoEditorView.frame.maxX-rightBtn.frame.width, y: videoEditorView.frame.origin.y, width: 20, height: videoEditorView.frame.height)
                
            }else  if videoEditorView.frame.maxX+(currentTouchPoint.x-self.previousPoint.x) < videoEditorView.frame.origin.x+cellW+20 {
                
                videoEditorView.frame = CGRect(x: videoEditorView.frame.origin.x , y: videoEditorView.frame.origin.y, width: cellW+20, height: videoEditorView.frame.size.height)
                
                
                //                rightBtn.frame = CGRect(x: videoEditorView.frame.maxX-rightBtn.frame.width, y: videoEditorView.frame.origin.y, width: 20, height: videoEditorView.frame.height)
                
            }else{
                
                videoEditorView.frame = CGRect(x: videoEditorView.frame.origin.x, y: videoEditorView.frame.origin.y, width: videoEditorView.frame.size.width+(currentTouchPoint.x-self.previousPoint.x), height: videoEditorView.frame.size.height)
                rightBtn.frame = CGRect(x: videoEditorView.frame.maxX-rightBtn.frame.width, y: videoEditorView.frame.origin.y, width: 20, height: videoEditorView.frame.height)
            }
            
            
            self.previousPoint = sender.location(in: self.view)
            self.slidingright()
        }
    }
    open  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoTimecopy
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YVVideoEditorViewController", for: indexPath) as! YVSplitVideoCell
        DispatchQueue.global().async {
            let imageGenerator: AVAssetImageGenerator  = AVAssetImageGenerator(asset: self.yvvideoAsset)
            imageGenerator.apertureMode  = AVAssetImageGeneratorApertureModeEncodedPixels
            imageGenerator.appliesPreferredTrackTransform = true
            let time: CMTime = CMTimeMake(Int64(Int(self.yvvideoAsset.duration.timescale)*(indexPath.row)+1), self.yvvideoAsset.duration.timescale)
            do {
                let cgImage =  try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: cgImage)
                image.yv_asyncDrawImage(rect: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), isCorner: false, backColor: nil, finished: { (yvimage) in
                    cell.imageV.image = yvimage
                })
            } catch {
            }
        }
        return cell
    }
    open  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.videoPlayer.pause()
    }
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentSize.width != 0 {
            startt = Int64(CGFloat((scrollView.contentOffset.x - (-videoEditorView.frame.origin.x))/scrollView.contentSize.width)*CGFloat(yvvideoAsset.duration.value))
            starttCopy = startt+continuoust
            self.videoPlayer.seek(to: CMTimeMake(startt, yvvideoAsset.duration.timescale), toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    open  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            startt = Int64(CGFloat((scrollView.contentOffset.x - (-videoEditorView.frame.origin.x))/scrollView.contentSize.width)*CGFloat(yvvideoAsset.duration.value))
            starttCopy = startt+continuoust
            self.videoPlayer.seek(to: CMTimeMake(startt, yvvideoAsset.duration.timescale))
            
            self.videoPlayer.play()
        }else{}
    }
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        startt = Int64(CGFloat((scrollView.contentOffset.x - (-videoEditorView.frame.origin.x))/scrollView.contentSize.width)*CGFloat(yvvideoAsset.duration.value))
        starttCopy = startt+continuoust
        self.videoPlayer.seek(to: CMTimeMake(startt, yvvideoAsset.duration.timescale))
        self.videoPlayer.play()
    }
    public func yvdidleftitem() {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func yvdidrightitem() {
        self.videoPlayer.pause()
        let  YVfileManager = FileManager.default
        if YVfileManager.fileExists(atPath: self.outputVideoUrl.path) {
            do {
                try YVfileManager.removeItem(atPath: self.outputVideoUrl.path)
                print("remove success")
            }catch{
                print("remove failed")
            }
        }
        YVLoadinger.shared.show()
        YVSplitVideoManager.shared.yvSplitVideo(self.inputVideoUrl, videoTimeRange: CMTimeRange(start: CMTimeMake(startt, yvvideoAsset.duration.timescale), duration: CMTimeMake(continuoust, yvvideoAsset.duration.timescale)), outUrl: self.outputVideoUrl) { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
                self?.finished((self?.outputVideoUrl)!)
                YVLoadinger.shared.dismiss()
                self?.view.isUserInteractionEnabled = true
            }
        }
    }
}
