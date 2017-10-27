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
	var videoMp4URL: URL?
	var videoMovURL: URL?
	var audioM4aURL: URL?
	var audioWavURL: URL?
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
        
        videoMp4URL = info["UIImagePickerControllerReferenceURL"] as? URL
		print("=====videoMp4URL is =====")
		print(videoMp4URL!)
        imageView.image = previewImageFromVideo(videoMp4URL!)!
        imageView.contentMode = .scaleAspectFit
        imagePickerController.dismiss(animated: true, completion: nil)	// 写真選択画面を閉じる
		
		// 動画から音声を抽出
		audioM4aURL = extractM4aFromMp4(videoMp4URL!)!
    }
    
    //アップロードした動画をアプリ内に保存する

    
    func saveVideo(_ url: URL){
        print("動画を保存")

        // Exportするときに必要なもろもろのもの
        let asset = AVAsset(url: url)
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
        // DocumentDirectoryのPathをセット
        let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        // 出力する音声ファイルの名称とPathをセット
        let exportPath: String = documentPath + "/" + "videoOutput.mp4"        //拡張子を".mp4"に指定
        // 最終的に出力する音声ファイルのパスをexportUrlに代入
        let exportUrl: URL = URL(fileURLWithPath: exportPath)
        
        // Exporterにもろもろのものをセットする
        exporter?.outputFileType = AVFileType.mp4                           //拡張子を".mp4"に指定
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
        //ここ
        print(documentPath)
    }
    func previewImageFromVideo(_ url: URL) -> UIImage? {
        
        print("動画からサムネイルを生成する")
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset:asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
		print(time)
        saveVideo(videoMp4URL!)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            return nil
        }
    }
	
	/* --- TODO: wavファイルのPathとURLを生成メソッドを書く --- */

	
	/* mp4形式の動画から音声をm4a形式で抽出 */
	func extractM4aFromMp4(_ url: URL) -> URL? {
		print("動画から音声を抽出する")
		
		/* --- TODO: 引数がmp4以外だったときのエラー処理を書く --- */

		// Exportするときに必要なもろもろのもの
		let asset = AVAsset(url: url)
		let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough)
		// DocumentDirectoryのPathをセット
		let documentPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		// 出力する音声ファイルの名称とPathをセット
		let exportPath: String = documentPath + "/" + "audioOutput.m4a"		//拡張子を".m4a"に指定
		// 最終的に出力する音声ファイルのパスをexportUrlに代入
		let exportUrl: URL = URL(fileURLWithPath: exportPath)
		
		// Exporterにもろもろのものをセットする
		exporter?.outputFileType = AVFileType.m4a							//拡張子を".m4a"に指定
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
		
		return exportUrl
	}
	
    //動画の再生
    @IBAction func playMovie(_ sender: Any) {
        if let videoMp4URL = videoMp4URL {
            let player = AVPlayer(url: videoMp4URL as URL)
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
			player = try AVAudioPlayer(contentsOf: audioM4aURL!)
			print("音声再生")
			player.play()
		} catch {
			print("player initialization error")
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
