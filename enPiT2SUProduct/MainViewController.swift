//
//  MainViewController.swift
//
//  Created by team-E on 2017/10/19.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import AVKit
import DZNEmptyDataSet

/* メイン画面のController */
class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
	
	var window: UIWindow?
	var videoMp4URL: URL?
	var videoMovURL: URL?
	var audioM4aURL: URL?
	var audioWavURL: URL?
	var player: AVAudioPlayer!
    let imagePickerController = UIImagePickerController()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // StatusBarの設定
        let statusBar = StatusBar(.orange)
        view.addSubview(statusBar)
        
        // DZNEmptyDataSetの設定
        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        tableView.tableFooterView = UIView();
    }
    
    /* メモリエラーが発生したとき */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 動画を選択する */
    @IBAction func selectImage(_ sender: Any) {
        print("カメラロールから動画を選択")
        
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        // 動画だけ表示
        imagePickerController.mediaTypes = ["public.movie"]

        present(imagePickerController, animated: true, completion: nil)
    }
	
    /* 動画を選択したとき */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoMovURL = info["UIImagePickerControllerReferenceURL"] as? URL
		print("===== videoMp4URL is =====")
		print(videoMovURL!)
        
        imageView.image = previewImageFromVideo(videoMovURL!)!
        imageView.contentMode = .scaleAspectFit
        
        // 動画選択画面を閉じる
        imagePickerController.dismiss(animated: true, completion: nil)
		
        // 動画から音声を抽出
        videoMp4URL = FileManager.save(videoMovURL!, "videoOutput", .mp4)
        audioM4aURL = FileManager.save(videoMp4URL!, "audioOutput", .m4a)
    }
    
    /* 動画からサムネイルを生成する */
    func previewImageFromVideo(_ url: URL) -> UIImage? {
        print("動画からサムネイルを生成する")
        
        let asset = AVAsset(url: url)
        
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
	
	/* --- TODO: wavファイルのPathとURLを生成するメソッドを書く --- */
	
    /* 動画の再生 */
    @IBAction func playMovie(_ sender: Any) {
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        // 出力する音声ファイルの名称とPathをセット
        let exportPath: String = documentPath + "/" + "videoOutput.mp4"
        
        if let videoMp4URL = videoMp4URL {
            let player = AVPlayer(url: videoMp4URL as URL)
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        } else {
            let video = loadVideo(URL(fileURLWithPath: exportPath))
            
            let playerViewController = AVPlayerViewController()
            playerViewController.player = video
            
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
    }
	
	/* 音声の再生 */
	@IBAction func playAudio(_ sender: Any) {
		do {
            print("音声再生")
			player = try AVAudioPlayer(contentsOf: audioM4aURL!)
			player.play()
		} catch {
			print("player initialization error")
		}
	}
    
    /* 動画を読み込む */
    func loadVideo(_ url: URL) -> AVPlayer{
        print("動画の読み込み")
        
        let videoName = "videoOutput.mp4"
        var video: AVPlayer?
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path_file_name = dir.appendingPathComponent(videoName)
            video = AVPlayer(url: path_file_name)
        }
        
        return video!
    }
	
    /* TableViewが空のときに表示する内容のタイトルを設定 */
	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let text = "No Movies"
		let font = UIFont.systemFont(ofSize: 30)
        
		return NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font])
	}
	
    /* TableViewが空のときに表示する内容の詳細を設定 */
	func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let paragraph = NSMutableParagraphStyle()
		paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
		paragraph.alignment = NSTextAlignment.center
		paragraph.lineSpacing = 6.0
        
		return NSAttributedString(
			string: "Upload your movies.",
			attributes:  [
				NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0),
				NSAttributedStringKey.paragraphStyle: paragraph
			]
		)
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
