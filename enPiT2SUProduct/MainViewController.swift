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
	var translation: String = ""
    var captions: Caption!

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
        
        // NavigationBarの右側にEditButtonを設置
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.image = UIImage(named: "Edit")
        
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
                
                // ImagePickerControllerの設定
                let imagePickerController = UIImagePickerController()
                imagePickerController.sourceType = .photoLibrary
                imagePickerController.delegate = self
                imagePickerController.mediaTypes = ["public.movie"]
                
                // PhotoLibraryの表示
                self.present(imagePickerController, animated: true, completion: nil)
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
        let label = convertFormat(name)
        
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
        
        // MOVからM4aに変換
        audioM4aURL = FileManager.save(videoMovURL!, name, .m4a)
        print("---> M4a URL")
        print(audioM4aURL!)
        print("<--- M4a URL")
        
        // メインスレッドで処理
        let lockQueue = DispatchQueue.main
        lockQueue.async {
            // 動画選択画面を閉じる
            picker.dismiss(animated: true, completion: nil)
        }
        
        // KRProgressHUDの開始
        KRProgressHUD.show(withMessage: "Uploading...")
		
        // 字幕を生成
        generateCaption()
		
        // TableViewにCellを追加
        videos.append(VideoInfo(name, image, label))
        
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
        settings.smartFormatting = true
        
        // 音声認識に失敗したときの処理
        let failure = { (error: Error) in
            print(error)
            
            self.failure()
        }
        
        // 音声認識に成功したときの処理
        let success = { (results: SpeechRecognitionResults) in
            self.captions = Caption(results)
            
            print("---> Times")
            print("Sentence: \(self.captions.sentences[0].sentence!), Start: \(self.captions.sentences[0].startTime!), End: \(self.captions.sentences[0].endTime!)")
            let count = self.captions.sentences.count
            print("Sentence: \(self.captions.sentences[count-1].sentence!), Start: \(self.captions.sentences[count-1].startTime!), End: \(self.captions.sentences[count-1].endTime!)")
            print("<--- Times")
            
            // 認識結果を字幕に設定
            var caption = ""
            for sentence in self.captions.sentences {
                caption += sentence.sentence! + "。"
            }
        
            print("---> Caption")
            print(caption)
            print("<--- Caption")
            
            self.videos[self.videos.count-1].caption = caption
			
			self.translateCaption(caption)
            
            self.success()
        }
        
        // 音声認識の実行
        speechToText.recognize(audio: speechUrl, settings: settings, model: "ja-JP_BroadbandModel",
                               customizationID: nil, learningOptOut: true, failure: failure, success: success)
    }
    
    /* 字幕の翻訳 */
    func translateCaption(_ caption: String) {
        
        let translator = Translation()
        
        let translationInfo = TranslationInfo(sourceLanguage: "ja", targetLanguage: "en", text: caption)
        
        translator.translate(params: translationInfo) { (result) in
            self.translation = "\(result)"
            print("---> Translation")
            print(result)
            print("<--- Translation")
        }
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
    
    /* 編集モードの変更 */
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        tableView.setEditing(editing, animated: animated)
    }
    
    /* 編集可能なCellを設定 */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* Cellの削除 */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // 先にデータを更新する
        videos.remove(at: indexPath.row)
        
        // それからテーブルの更新
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        tableView.reloadData()
    }
    
    /* 移動可能なCellを設定 */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /* Cellの移動 */
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceIndex = sourceIndexPath.row
        let destinationIndex = destinationIndexPath.row
        
        if sourceIndex >= 0 && sourceIndex < videos.count && destinationIndex >= 0 && destinationIndex < videos.count {
            let video = videos[sourceIndex]
            
            videos.remove(at: sourceIndex)
            videos.insert(video, at: destinationIndex)
        }
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
            subVC.receivedCaption = captions
			subVC.receivedTranslation = translation
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
    
    /* 時刻表示の形式をいい感じに変更 */
    func convertFormat(_ date: String) -> String {
        let splittedDate = date.split(separator: "-")
        let convertedDate = String(splittedDate[0]) + "/" + String(splittedDate[1]) + "/" + String(splittedDate[2]) + "/" + String(splittedDate[3]) + ":" + String(splittedDate[4]) + ":" + String(splittedDate[5])
        return convertedDate
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
