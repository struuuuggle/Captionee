//
//  SubViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/05.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import AVKit

class SubViewController: UIViewController{
	
	var receivedVideoInfo: VideoInfo!
	var receivedTranslation: String!
    
    var player: AVPlayer!
    var timeObserverToken: Any!
	
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var translation: UILabel!
	
	override func viewDidLoad() {
		super.viewDidLoad()
        print("ViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        //navigationController?.navigationBar.isHidden = true
        
        // DocumentDirectoryのPath
        let documentPath: String = FileManager.documentDir
        
        // 動画のURL
        let url = URL(fileURLWithPath: documentPath + "/" + receivedVideoInfo.name + ".mp4")
        
        // AVPlayerを生成
        player = AVPlayer(url: url)
        
        // AVPlayerViewControllerの設定
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height/2)
        playerViewController.showsPlaybackControls = true
        
        // TimeObserverを設定
        addPeriodicTimeObserver()
        
        // AVPlayerViewControllerをViewControllerに追加
        addChildViewController(playerViewController)
        
        // 最大画面になった時、これが使用される感じ
        view.addSubview(playerViewController.view)
        
        // 字幕のLabelのサイズを設定
        caption.frame = CGRect(x: 10, y: view.bounds.size.height*2/5, width: view.bounds.size.width-20, height: view.bounds.size.height/5)
        
        // 翻訳のLabelのサイズを設定
		translation.frame = CGRect(x: 10, y: view.bounds.size.height*3/5, width: view.bounds.size.width-20, height: view.bounds.size.height/5)
        
        // 字幕を表示
        caption.text = ""
		
		// 翻訳結果を表示
		translation.text = receivedTranslation
	}
    
    /* 一定時間ごとに動画の再生状態を監視する */
    func addPeriodicTimeObserver() {
        // 監視の時間間隔
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        // メインスレッド
        let mainQueue = DispatchQueue.main
        
        // TimeObserverを生成
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            // 現在の動画の再生時間を取得
            let currentTime = time.seconds
            print(currentTime)
            
            // 字幕を適切なタイミングで表示
            if let captions = self?.receivedVideoInfo.caption {
                for caption in captions.sentences {
                    if currentTime >= caption.startTime && currentTime <= caption.endTime {
                        self?.caption.text = caption.sentence + "。"
                        break
                    }
                }
            } else {
                self?.caption.text = "Caption is nil."
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("ViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("ViewController/viewWillDisappear/別の画面に遷移する直前")
        
        // 動画の再生を止める
        player.pause()
        
        // TimeObserverを廃棄
        timeObserverToken = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
    }
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
        print("ViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
	}
}
