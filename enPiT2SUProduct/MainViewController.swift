//
//  MainViewController.swift
//  
//
//  Created by 池崎雄介 on 2017/10/19.
//

import UIKit
import AVKit
import DZNEmptyDataSet
import AVFoundation

class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
	
    let imagePickerController = UIImagePickerController()
	var window: UIWindow?
	var videoURL: URL?
	var audioURL: URL?
	var player: AVAudioPlayer!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //動画の選択
    @IBAction func selectImage(_ sender: Any) {
        print("UIBarButtonItem。カメラロールから動画を選択")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        //imagePickerController.mediaTypes = ["public.image", "public.movie"]
        //動画だけ
        imagePickerController.mediaTypes = ["public.movie"]
        //画像だけ
        //imagePickerController.mediaTypes = ["public.image"]
        present(imagePickerController, animated: true, completion: nil)
		
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        statusBar.backgroundColor = UIColor.orange
        view.addSubview(statusBar)
        
        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        tableView.tableFooterView = UIView();
		
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
    // 写真選択時に呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        videoURL = info["UIImagePickerControllerReferenceURL"] as? URL
		print("=====videoURL is =====")
		print(videoURL!)
        imageView.image = previewImageFromVideo(videoURL!)!
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)	// 写真選択画面を閉じる
		
		extractAudioFromVideo(videoURL!)
    }
    
    func previewImageFromVideo(_ url: URL) -> UIImage? {
        
        print("動画からサムネイルを生成する")
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
		print(time)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
	
	/* 動画から音声を抽出 */
	func extractAudioFromVideo(_ url: URL) {
		print("動画から音声を抽出する")
		let asset = AVAsset(url: url)
		
//		audioTrack = asset.tracks(withMediaType: AVMediaType.audio)[0] // アセットからトラックを取得
		// AssetにInputとなるファイルのUrlをセット
		// cafファイルとしてExportする
		let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
		let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		let exportPath: String = documentPath + "/" + "audioOutput.m4a"
		let exportUrl: URL = URL(fileURLWithPath: exportPath)
		
		exporter?.outputFileType = AVFileType.caf
		exporter?.outputURL = exportUrl
		exporter?.shouldOptimizeForNetworkUse = true
		
		// ファイルが存在している場合は削除
		if FileManager.default.fileExists(atPath: exportPath) {
			try! FileManager.default.removeItem(atPath: exportPath)
		}
		
		// Export
		exporter!.exportAsynchronously(completionHandler: {
			switch exporter!.status {
			case .completed:
				print("Success!")
				self.audioURL = exportUrl
				print("audioURL is")
				print(self.audioURL!)
			case .failed, .cancelled:
				print("error = \(String(describing: exporter?.error))")
			default:
				print("error = \(String(describing: exporter?.error))")
			}
		})
	}
	
    //動画の再生
    @IBAction func playMovie(_ sender: Any) {
        
        if let videoURL = videoURL{
            let player = AVPlayer(url: videoURL as URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true){
                print("動画再生")
                playerViewController.player!.play()
            }
        }
    }
	
	/* 音声の再生 */
	@IBAction func playAudio(_ sender: Any) {
		do {
			player = try AVAudioPlayer(contentsOf: audioURL!)
			print("音声再生")
			player.play()
		} catch {
			print("error")
		}
	}
	

	func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
		let text = "No Movies"
		let font = UIFont.systemFont(ofSize: 30)
		return NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font])
	}
	
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
