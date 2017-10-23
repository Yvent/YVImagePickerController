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
    
    func yvSplitVideo(_ musicUrl: URL, videoTimeRange: CMTimeRange, outUrl: URL, finished: @escaping (()->())  ) {
        
        let musicAsset = AVURLAsset(url: musicUrl, options: nil)
        let exportSession = AVAssetExportSession(asset: musicAsset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = outUrl
        exportSession?.timeRange = videoTimeRange
        exportSession?.outputFileType = AVFileTypeQuickTimeMovie
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
