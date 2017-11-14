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
    static func save(_ url: URL, _ name: String, _ type: AVFileType) -> URL{
        print("---> Save File")
        
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
        let exportUrl: URL = URL(fileURLWithPath: exportPath)
        
        // Exportするときに必要なもろもろのもの
        let asset = AVAsset(url: url)
        print("---> Asset")
        print(asset)
        print("<--- Asset")
        
        // Exporterにもろもろのものをセットする
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        exporter?.outputFileType = type
        exporter?.outputURL = exportUrl
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
        
        print("<--- Save File")
        
        return exportUrl
    }
    
}
