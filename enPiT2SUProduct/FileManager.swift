//
//  FileManager.swift
//
//  Created by team-E on 2017/10/29.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import AVFoundation

/* FileManagerの拡張 */
extension FileManager {
    
    /* DocumentDirectoryへのPath */
    static var documentDir: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }
    
    /* DocumentDirectoryにファイルを保存する */
    static func save(_ sourceURL: URL, _ name: String, _ type: AVFileType) -> URL{
        print("---------> Save File \(type)")
        
        // DocumentDirectoryのPathをセット
        let documentPath: String = FileManager.documentDir
        print("---> DocumentPath")
        print(documentPath)
        print("<--- DocumentPath")
        
        // 出力するファイル名の設定
        var fileName = name
        switch type {
        case .mp4: fileName += ".mp4"
        case .m4a: fileName += ".m4a"
        case .wav: fileName += ".wav"
        default: print("Invalid extension")
        }
        print("---> FileName")
        print(fileName)
        print("<--- FileName")
        
        // 出力するファイルのPathを設定
        let exportPath: String = documentPath + "/" + fileName
        // 最終的に出力するファイルのパスをexportUrlに代入
        let exportURL: URL = URL(fileURLWithPath: exportPath)
        
        // Exportするときに必要なソースアセット
        var asset = AVAsset(url: sourceURL)
        if type == .m4a {
            asset = prepareForM4a(asset)!
        }
        print("---> Asset")
        print(asset)
        print("<--- Asset")
        
    
        // Exportの準備
        var exporter: AVAssetExportSession?
        switch type {
        case .mp4: exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        case .m4a: exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A)
        case .wav: exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        default: print("Invalid extension")
        }
        exporter?.outputFileType = type
        exporter?.outputURL = exportURL
        exporter?.shouldOptimizeForNetworkUse = true
        
        // 出力したいパスに既にファイルが存在している場合は、既存のファイルを削除する
        if FileManager.default.fileExists(atPath: exportPath) {
            try! FileManager.default.removeItem(atPath: exportPath)
        }
        
        // Export
        exporter!.exportAsynchronously(completionHandler: {
            switch exporter!.status {
            case .completed:
                print("Exportation Success!")
            case .failed, .cancelled:
                print("Exportation error = \(String(describing: exporter?.error))")
            default:
                print("Exportation error = \(String(describing: exporter?.error))")
            }
        })
        
        print("<--------- Save File \(type)")
        return exportURL
    }
    
    /* 動画から音声の抽出 */
    static func prepareForM4a(_ asset: AVAsset) -> AVAsset? {
        print("---> prepareForM4a")
        // Create a composition
        let composition = AVMutableComposition()
        do {
            guard let audioAssetTrack = asset.tracks(withMediaType: AVMediaType.audio).first else { return nil }
            let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try audioCompositionTrack?.insertTimeRange(audioAssetTrack.timeRange, of: audioAssetTrack, at: kCMTimeZero)
        } catch {
            print(error)
        }
        print("<--- prepareForM4a")
        return composition
    }
}
