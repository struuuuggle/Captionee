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
    var receivedCaption: String!
	
	@IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var caption: UILabel!
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
		// 選択された動画のサムネイルを表示
		imageView.image = receivedVideoInfo.image
		// 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
		imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        // 字幕を表示
        caption.text = receivedCaption
	}
	
	/* 動画の再生 */
	func playVideo(_ name: String) {
        print("動画の再生")
        
        let documentPath: String = FileManager.documentDir
        
		let url = URL(fileURLWithPath: documentPath + "/" + name + ".mp4")
        
		let player = AVPlayer(url: url)
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.view.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 300)
        playerViewController.showsPlaybackControls = true
        playerViewController.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        
        addChildViewController(playerViewController)
        
        // 最大画面になった時、これが使用される感じ
        view.addSubview(playerViewController.view)
        
        player.play()
	}
	
	/* サムネイルをタップしたときの動作 */
	@IBAction func imageTapped(_ sender: AnyObject) {
		playVideo(receivedVideoInfo.name)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
