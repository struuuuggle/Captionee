//
//  MainViewController.swift
//
//  Created by team-E on 2017/10/19.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import AVKit
import Photos
import DZNEmptyDataSet
import KRProgressHUD
import MaterialComponents
import SpeechToTextV1

/* メイン画面のController */
class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var window: UIWindow?
    var videoMovURL: URL?
    var videoMp4URL: URL?
    var audioM4aURL: URL?
    var audioWavURL: URL?
    var videos = [VideoInfo]()
    var speechToText: SpeechToText!
    var selectedVideoInfo: VideoInfo?
    var caption: String = ""
    //var captions: Caption!
    
    let imagePickerController = UIImagePickerController()

    @IBOutlet weak var tableView: UITableView!
    
    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // NavigationBarの左側にMenuButtonを設置
        let menuButton = UIBarButtonItem(image: UIImage(named: "Menu"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(menuButtonTapped))
        navigationItem.leftBarButtonItem = menuButton
        
        // Viewの背景色を設定
        view.backgroundColor = MDCPalette.grey.tint100
        
        // DZNEmptyDataSetのSourceとDelegateを設定
        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        
        // TableViewのSeparatorを消す
        tableView.tableFooterView = UIView(frame: .zero);
        
        // SpeechToTextのUsernameとPasswordを設定
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        navigationItem.rightBarButtonItem = editButtonItem
        
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
        print("Menu button tapped.")
    }
    
    /* メモリエラーが発生したとき */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* PhotoLibraryから動画を選択する */
    @IBAction func selectImage(_ sender: Any) {
        print("カメラロールから動画を選択")
        
        // 初回のみ実行
        requestAuth()
    }
    
    /* PhotoLibraryの利用許可 */
    func requestAuth() {
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch(status){
            case .authorized:
                print("Authorized")
                
                // PhotoLibraryの設定
                self.imagePickerController.sourceType = .photoLibrary
                self.imagePickerController.delegate = self
                self.imagePickerController.mediaTypes = ["public.movie"]
                
                // PhotoLibraryの表示
                self.present(self.imagePickerController, animated: true, completion: nil)
            case .denied:
                print("Denied")
                
                self.failure()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        }
    }
    
    /* PhotoLibraryで動画を選択したとき */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        videoMovURL = info["UIImagePickerControllerReferenceURL"] as? URL
        print("---> MOV URL")
        print(videoMovURL!)
        print("<--- MOV URL")
        
        // VideoInfoの設定
        let name = getCurrentTime()
        let image = previewImageFromVideo(videoMovURL!)!
        let label = "No.\(videos.count + 1)"
        
        /*
        // サブスレッドで処理
        let queue = DispatchQueue(label: "lockQueue")
        queue.async {
            // 動画から音声を抽出
            self.videoMp4URL = FileManager.save(self.videoMovURL!, name, .mp4)
            print("---> MP4 URL")
            print(self.videoMp4URL!)
            print("<--- MP4 URL")
            
            sleep(1)
        
            self.audioM4aURL = FileManager.save(self.videoMp4URL!, name, .m4a)
            print("---> M4a URL")
            print(self.audioM4aURL!)
            print("<--- M4a URL")
        }
        */
        
        // MOVからMP4に変換
        videoMp4URL = FileManager.save(videoMovURL!, name, .mp4)
        print("---> MP4 URL")
        print(videoMp4URL!)
        print("<--- MP4 URL")
        
        
        audioM4aURL = FileManager.save(videoMovURL!, name, .m4a)
        print("---> M4a URL")
        print(audioM4aURL!)
        print("<--- M4a URL")
        
        // メインスレッドで処理
        let lockQueue = DispatchQueue.main
        lockQueue.async {
            // 動画選択画面を閉じる
            self.imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        // KRProgressHUDの開始
        KRProgressHUD.show(withMessage: "Uploading...")
        
        generateCaption()
        
        // TableViewにCellを追加
        videos.append(VideoInfo(name, image, label, caption))
        
        // TableViewの更新
        tableView.reloadData()
    }
    
    /* 動画からサムネイルを生成する */
    func previewImageFromVideo(_ url: URL) -> UIImage? {
        print("動画からサムネイルを生成")
        
        // Assetの取得
        let asset = AVAsset(url: url)
        
        // ImageGeneratorを生成
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        // 動画中のサムネイルにする場面の時間を設定
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            // サムネイルを生成
            let image = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            
            // cropするサイズを設定
            let size = min(image.width, image.height)
            
            // サムネイルを正方形にcropする
            let croppedImage = image.cropping(to: CGRect(x: 0, y: 0, width: size, height: size))!
            
            return UIImage(cgImage: croppedImage)
        } catch {
            return nil
        }
    }
    
    /* 字幕を生成する */
    func generateCaption() {
        print("字幕を生成")
        
        // 対象ファイルのURL
        let speechUrl = Bundle.main.url(forResource: "simple", withExtension: "wav")!
        
        // 音声認識の設定
        var settings = RecognitionSettings(contentType: .wav)
        settings.timestamps = true
        settings.wordConfidence = true
        
        // 音声認識に失敗したときの処理
        let failure = { (error: Error) in
            print(error)
            
            self.failure()
        }
        
        // 音声認識に成功したときの処理
        let success = { (results: SpeechRecognitionResults) in
            print(results.results)
            
            let times = results.results[1].alternatives[0].timestamps![0]
            print("---> Times")
            print("Word: \(times.word), Start: \(times.startTime), End: \(times.endTime)")
            print("<--- Times")
            
            /*
            var words = [[String]]()
            var startTimes = [[Double]]()
            var endTimes = [[Double]]()
            
            var index = 0
            for result in results.results {
                for timestamp in result.alternatives[0].timestamps! {
                    words[index].append(timestamp.word)
                    startTimes[index].append(timestamp.startTime)
                    endTimes[index].append(timestamp.endTime)
                }
                index += 1
            }
            
            print(words)
            
            self.captions = Caption(words, startTimes, endTimes)
            */
            
            // 認識結果を字幕に設定
            self.caption = results.bestTranscript
        
            print("---> Caption")
            print(self.caption)
            print("<--- Caption")
            
            self.success()
        }
        
        // 音声認識の実行
        speechToText.recognize(audio: speechUrl, settings: settings, model: "ja-JP_BroadbandModel",
                               customizationID: nil, learningOptOut: true, failure: failure, success: success)
    }
    
    /* 動画のアップロードに成功したとき */
    func success() {
        KRProgressHUD.dismiss() {
            KRProgressHUD.showSuccess(withMessage: "Successfully uploaded!")
        }
    }
    
    /* 動画のアップロードに失敗したとき */
    func failure() {
        KRProgressHUD.dismiss() {
            KRProgressHUD.showError(withMessage: "Uploading failed.")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // 先にデータを更新する
        videos.remove(at: indexPath.row)
        
        // それからテーブルの更新
        //tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* Cellの個数を指定 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    /* Cellに値を設定 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの指定
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        // Cellのサムネイル画像を設定
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = videos[indexPath.row].image
        imageView.contentMode = .scaleAspectFit
        
        // Cellの説明を設定
        let label = cell.viewWithTag(2) as! UILabel
        label.text = videos[indexPath.row].label
        
        return cell
    }
    
    /* Cellの高さを設定 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 画面の縦サイズ
        let screenHeight = UIScreen.main.bounds.size.height
        
        // StatusBarの縦サイズ
        let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        
        // NavigationBarの縦サイズ
        let navBarHeight = navigationController!.navigationBar.frame.size.height
        
        // 表示するCellの個数
        let cellNumber: CGFloat = 5
        
        // Cellの高さ
        let cellHeight = (screenHeight - statusBarHeight - navBarHeight) / cellNumber

        return cellHeight
    }
    
    /* Cellが選択されたとき */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Cellが選択されました")
        
        print("---> VideoName")
        print(videos[indexPath.row].name)
        print("<--- VideoName")
        
        // 選択されたセルの動画情報をprepareメソッドに渡すためにselectedVideoInfoに一時保管
        selectedVideoInfo = videos[indexPath.row]
        
        // SubViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toSubViewController", sender: nil)
        
        // Cellの選択状態を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /* Segueの準備 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            /*
            if let cell = sender as? UITableViewCell {
                print("prepare")
                let indexPath = self.tableView.indexPath(for: cell)!
                let subVC = segue.destination as! SubViewController
                subVC.receivedVideoInfo = self.videos[indexPath.row]
            }
            */
            
            // 遷移先のViewControllerを設定
            let subVC = segue.destination as! SubViewController
            
            // 値の受け渡し
            subVC.receivedVideoInfo = selectedVideoInfo
            subVC.receivedCaption = caption
            //subVC.receivedCaptions = captions
        }
    }
    
    /* TableViewが空のときに表示する内容のタイトルを設定 */
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // TableViewの背景色を設定
        scrollView.backgroundColor = MDCPalette.grey.tint100
        
        // テキストを設定
        let text = "No movie uploaded."
        
        // フォントを設定
        let font = MDCTypography.titleFont()
        
        return NSAttributedString(string: text, attributes: [NSAttributedStringKey.font: font])
    }
    
    /* TableViewが空のときに表示する内容の詳細を設定 */
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        // テキストを設定
        let text = "Let's upload your movies and\n watch them with caption!"
        
        // フォントを設定
        let font = MDCTypography.body1Font()
        
        // パラグラフを設定
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = NSLineBreakMode.byWordWrapping
        paragraph.alignment = NSTextAlignment.center
        paragraph.lineSpacing = 6.0
        
        return NSAttributedString(
            string: text,
            attributes:  [
                NSAttributedStringKey.font: font,
                NSAttributedStringKey.paragraphStyle: paragraph
            ]
        )
    }
    
    /* 現在時刻を文字列として取得 */
    func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let now = Date()
        return formatter.string(from: now)
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
