//
//  SubViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/05.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import Foundation
import UIKit
import AVKit

class SubViewController: UIViewController{
	
	var receivedVideoInfo: VideoInfo!
	
	@IBOutlet weak var imageView: UIImageView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// 選択された動画のサムネイルを表示
		imageView.image = receivedVideoInfo.image
		// 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
		imageView.contentMode = UIViewContentMode.scaleAspectFit
	}
	
	/* 動画の再生 */
	func playVideo(_ name: String) {
		let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		let url = URL(fileURLWithPath: documentPath + "/" + name + ".mp4")
		let player = AVPlayer(url: url)
		let playerViewController = AVPlayerViewController()
		
		playerViewController.player = player
		
		present(playerViewController, animated: true){
			print("動画再生")
			playerViewController.player!.play()
		}
	}
	
	/* サムネイルをタップしたときの動作 */
	@IBAction func imageTapped(_ sender: AnyObject) {
		playVideo(receivedVideoInfo.name)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
