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
import SpeechToTextV1

/* メイン画面のController */
class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource, AVAudioPlayerDelegate {
    
    var window: UIWindow?
    var videoMovURL: URL?
    var videoMp4URL: URL?
    var audioM4aURL: URL?
    var audioWavURL: URL?
    var videos = [VideoInfo]()
    var speechToText: SpeechToText!
    var audioPlayer: AVAudioPlayer!
    var speechUrl: URL!
    var selectedVideoInfo: VideoInfo?
    
    let imagePickerController = UIImagePickerController()

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // StatusBarの設定
        //let statusBar = StatusBar(.orange)
        //view.addSubview(statusBar)
                
        // DZNEmptyDataSetの設定
        tableView.emptyDataSetSource = self;
        tableView.emptyDataSetDelegate = self;
        
        // TableViewのSeparatorを消す
        tableView.tableFooterView = UIView(frame: .zero);
        
        // SpeechToTextの設定
        speechUrl = Bundle.main.url(forResource: "SpeechSample", withExtension: "wav")
        audioPlayer = try! AVAudioPlayer(contentsOf: speechUrl)
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        audioPlayer.delegate = self
    }
    
    /* メモリエラーが発生したとき */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* wavファイルの再生が終わったとき */
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play Audio File", for: .normal)
    }
    
    /* wavファイルの再生 */
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if !audioPlayer.isPlaying {
            playButton.setTitle("Stop Audio File", for: .normal)
            audioPlayer.currentTime = 0
            audioPlayer.play()
        } else {
            playButton.setTitle("Play Audio File", for: .normal)
            audioPlayer.stop()
        }
    }
    
    /* 音声を文字に起こす */
    @IBAction func transcribeButtonTapped(_ sender: UIButton) {
        var settings = RecognitionSettings(contentType: .wav)
        settings.interimResults = true
        let failure = { (error: Error) in print(error) }
        speechToText.recognize(audio: speechUrl, settings: settings, failure: failure) {
            results in
            print(results.bestTranscript)
        }
    }
    
    /* PhotoLibraryから動画を選択する */
    @IBAction func selectImage(_ sender: Any) {
        print("カメラロールから動画を選択")
        
        // ユーザーに許可を促す
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
        print("===== videoMp4URL is =====")
        print(videoMovURL!)
        
        let name = getCurrentTime()
        let image = previewImageFromVideo(videoMovURL!)!
        let label = "No.\(videos.count + 1)"
        
        videos.append(VideoInfo(name, image, label))
        
        // 動画選択画面を閉じる
        imagePickerController.dismiss(animated: true, completion: nil)
        
        // 動画から音声を抽出
        videoMp4URL = FileManager.save(videoMovURL!, name, .mp4)
        print("---> MP4 URL")
        print(videoMp4URL!)
        print("<--- MP4 URL")
        
        audioM4aURL = FileManager.save(videoMp4URL!, name, .m4a)
        print("---> M4a URL")
        print(audioM4aURL!)
        print("<--- M4a URL")
        
        // KRProgressHUDの開始
        KRProgressHUD.showOn(self).show(withMessage: "Processing...")
        
        generateCaption()
        
        // KRProgressHUDの終了
        KRProgressHUD.dismiss() {
            self.success()
        }
        
        tableView.reloadData()
    }
    
    /* 動画のアップロードに成功したとき */
    func success() {
        KRProgressHUD.showSuccess(withMessage: "Successfully processed!")
    }
    
    /* 動画のアップロードに失敗したとき */
    func failure() {
        KRProgressHUD.showError(withMessage: "Processing failed")
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
    
    /* 字幕を生成する */
    func generateCaption() {
        // Watsonにwavファイルを投げる
    }
    
    /* 音声の再生 */
    @IBAction func playAudio(_ sender: Any) {
        do {
            print("音声再生")
            let player = try AVAudioPlayer(contentsOf: audioM4aURL!)
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
    
    /* Cellの個数を指定 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    /* Cellに値を設定 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = videos[indexPath.row].image
        imageView.contentMode = .scaleAspectFit
        
        let label = cell.viewWithTag(2) as! UILabel
        label.text = videos[indexPath.row].label
        
        return cell
    }
    
    /* Cellの高さを設定 */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
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
            
            let subVC = segue.destination as! SubViewController
            subVC.receivedVideoInfo = selectedVideoInfo
        }
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
