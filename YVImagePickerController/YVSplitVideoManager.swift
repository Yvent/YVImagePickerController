//
//  YVSplitVideoManager.swift
//  Pods-YVImagePickerController-Demo
//
//  Created by Devil on 2017/10/20.
//

import UIKit
import AVFoundation

class YVSplitVideoManager: NSObject {
    static let shared = YVSplitVideoManager()
    private override init() {}
    
    func yvSplitVideo(_ asset: AVAsset, videoTimeRange: CMTimeRange? = nil, outUrl: URL, finished: @escaping (()->())  ) {
//        let videoAsset = AVURLAsset(url: musicUrl, options: nil)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = outUrl
        exportSession?.timeRange = videoTimeRange == nil ? CMTimeRange(start: kCMTimeZero, duration: kCMTimePositiveInfinity) : videoTimeRange!
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
        
        //删除本地重复视频
        if FileManager.default.fileExists(atPath: outUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: outUrl.path)
                print("Downloaded dir creat success")
            }catch{
                print("failed to create downloaded dir")
            }
        }
        exportSession?.exportAsynchronously(completionHandler: { () -> Void in
            
            switch exportSession!.status {
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
                finished()
            }
        })
    }
}
