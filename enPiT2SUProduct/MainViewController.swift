//
//  MainViewController.swift
//  enPiT2SUProduct
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
import SwiftReorder

/* メイン画面のController */
class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,
    DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var window: UIWindow?
    var videoMovURL: URL?
    var videoMp4URL: URL?
    var audioM4aURL: URL?
    var audioWavURL: URL?
    var speechToText: SpeechToText!
    var selectedVideoInfo: VideoInfo?
    var index: Int!
    var textField: MDCMultilineTextField!
    var editCompleteButton: MDCRaisedButton!
    var editCancelButton: MDCRaisedButton!
    var menuNumber: Int = 0
    let viewController = SideMenuController()
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var languageKey = "日本語" {
        willSet {
            // KRProgressHUDの開始
            KRProgressHUD.show(withMessage: "Uploading...")
        }
        didSet {
            print("Language is \(languageKey).")
            
            // 字幕を生成
            generateCaption()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectImageButton: MDCFloatingButton!
    
    var menuButton: UIBarButtonItem!
    
    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        // Do any additional setup after loading the view.
        
        // NavigationBarの左側にMenuButtonを設置
        menuButton = UIBarButtonItem(image: UIImage(named: "Menu"),
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
        
        tableView.reloadData()
        
        // SpeechToTextのUsernameとPasswordを設定
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(MainViewController.panGesture(sender:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        // スワイプ認識
        let directionList:[UISwipeGestureRecognizerDirection] = [.right, .left]
        for direction in directionList {
            let menuSwipe = UISwipeGestureRecognizer(target: self, action: #selector(MainViewController.swipeGesture(sender:)))
            menuSwipe.direction = direction
            self.view.addGestureRecognizer(menuSwipe)
        }
        

            
        tableView.reorder.delegate = self as TableViewReorderDelegate
        
        // TextFieldの設定
        textField = MDCMultilineTextField()
        textField.isHidden = true
        view.addSubview(textField)
        
        // 編集完了ボタンの設定
        editCompleteButton = MDCRaisedButton()
        editCompleteButton.setTitle("SAVE", for: .normal)
        editCompleteButton.titleLabel?.font = MDCTypography.buttonFont()
        editCompleteButton.backgroundColor = MDCPalette.lightBlue.tint500
        editCompleteButton.setTitleColor(UIColor.white, for: .normal)
        editCompleteButton.isHidden = true
        editCompleteButton.addTarget(self, action: #selector(editCompleteButtonTapped), for: .touchUpInside)
        view.addSubview(editCompleteButton)
        
        // 編集完了ボタンの制約を設定
        editCompleteButton.translatesAutoresizingMaskIntoConstraints = false
        editCompleteButton.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        editCompleteButton.trailingAnchor.constraint(equalTo: textField.trailingAnchor).isActive = true
        editCompleteButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
        editCompleteButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        // 編集キャンセルボタンの設定
        editCancelButton = MDCRaisedButton()
        editCancelButton.setTitle("CANCEL", for: .normal)
        editCancelButton.titleLabel?.font = MDCTypography.buttonFont()
        editCancelButton.backgroundColor = UIColor.white
        editCancelButton.setTitleColor(UIColor.black, for: .normal)
        editCancelButton.isHidden = true
        editCancelButton.addTarget(self, action: #selector(editCancelButtonTapped), for: .touchUpInside)
        view.addSubview(editCancelButton)
        
        // 編集キャンセルボタンの制約を設定
        editCancelButton.translatesAutoresizingMaskIntoConstraints = false
        editCancelButton.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true
        editCancelButton.trailingAnchor.constraint(equalTo: editCompleteButton.leadingAnchor, constant: -10).isActive = true
        editCancelButton.widthAnchor.constraint(equalToConstant: 88).isActive = true
        editCancelButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        viewController.view.isHidden = true
        
        
    }
    
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
    
        print("Menu button tapped.")
        
        if(menuNumber == 0){
            print("aaa")
        viewController.beginAppearanceTransition(true, animated: true)
        viewController.view.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
        }, completion: {_ in
            self.viewController.endAppearanceTransition()
        })

        view.addSubview(viewController.view)
            menuNumber = 1
            return
        }else{
            print("iii")
            viewController.beginAppearanceTransition(false, animated: true)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            }, completion: {_ in
                self.viewController.view.isHidden = true
                self.viewController.endAppearanceTransition()
            })
            viewController.view.isHidden = true

            menuNumber = 0
            return
        }
        
    }
    /* 以下は UITextFieldDelegate のメソッド */
    @objc func swipeGesture(sender: UISwipeGestureRecognizer){
        print("スワイプ")
        //スワイプした方向をラベルに表示する。
        switch(sender.direction){
        case UISwipeGestureRecognizerDirection.right:
            print("右")
        default:
            print("左")
        }
    }
    // クリアボタンが押された時の処理
    private func textFieldShouldClear(_ textField: MDCMultilineTextField) -> Bool {
        print("Clear")
        
        return true
    }
    
    /* 編集が完了されたとき */
    @objc func editCompleteButtonTapped() {
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        
        appDelegate.videos[index].label = textField.text!
        
        tableView.reloadData()
        selectImageButton.isEnabled = true
        self.tableView.allowsSelection = true
        
        textField.text = ""
    }
    
    /* 編集がキャンセルされたとき */
    @objc func editCancelButtonTapped() {
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        textField.text = ""
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
                
                self.showPhotoLibrary()
            case .denied:
                print("Denied")
                
                self.showDeniedAlert()
            case .notDetermined:
                print("NotDetermined")
            case .restricted:
                print("Restricted")
            }
        }
    }
    
    /* PhotoLibraryの全動画を表示する */
    func showPhotoLibrary() {
        // ImagePickerControllerの設定
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        // PhotoLibraryの表示
        present(imagePickerController, animated: true, completion: nil)
    }
    
    /* PhotoLibraryへのアクセスが拒否されているときにAlertを出す */
    func showDeniedAlert() {
        // AlertControllerを作成
        let alert = MDCAlertController(title: "エラー", message: "「写真」へのアクセスが拒否されています。設定より変更してください。")
        
        // AlertActionを作成
        let ok = MDCAlertAction(title: "SETTINGS", handler: { [weak self] (action) -> Void in
            guard let wself = self else {
                return
            }
            wself.transitionToSettingsApplition()
            
        })
        let cancel = MDCAlertAction(title: "CANCEL", handler: nil)
        
        // 選択肢をAlertに追加
        alert.addAction(ok)
        alert.addAction(cancel)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    /* iPhoneの「設定」を開く */
    fileprivate func transitionToSettingsApplition() {
        let url = URL(string: UIApplicationOpenSettingsURLString)
        if let url = url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        
        // TableViewにCellを追加
        appDelegate.videos.append(VideoInfo(name, image, label))
        
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
        
        //languageKey = "Japanese"
        
        // メインスレッドで処理
        let lockQueue = DispatchQueue.main
        lockQueue.async {
            let completion = { () in
                self.selectLanguage()
            }
            
            // 動画選択画面を閉じる
            picker.dismiss(animated: true, completion: completion)
        }
        
        // TableViewの更新
        tableView.reloadData()
    }
    
    /* 動画の言語の選択用ダイアログを表示する */
    func selectLanguage() {
        // AlertControllerを作成
        let alert = MDCAlertController(title: "言語選択", message: "動画の言語を選択してください")
        
        // AlertAction用ハンドラ
        let handler: MDCActionHandler = { (action) -> Void in
            self.languageKey = action.title!
        }
        
        // AlertActionを作成
        let chinese = MDCAlertAction(title: "中文", handler: handler)
        let ukEnglish = MDCAlertAction(title: "UK English", handler: handler)
        let usEnglish = MDCAlertAction(title: "English", handler: handler)
        let japanese = MDCAlertAction(title: "日本語", handler: handler)
        
        // 選択肢をAlertに追加
        // ダイアログ上では、以下のコードで先に追加したAlertActionほど下に表示される
        alert.addAction(chinese)
        alert.addAction(ukEnglish)
        alert.addAction(usEnglish)
        alert.addAction(japanese)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
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
            let captions = Caption(results)
            
            print("---> Caption")
            for sentence in captions.sentences {
                print("Sentence: \(sentence.original!), Start: \(sentence.startTime!), End: \(sentence.endTime!)")
            }
            print("<--- Caption")
            
            self.appDelegate.videos[self.appDelegate.videos.count-1].caption = captions
            
            self.success()
        }
        
        // 音声認識の言語モデルの辞書
        let languages = [
            "日本語": "ja-JP_BroadbandModel",
            "アメリカ英語": "en-GB_BroadbandModel",
            "イギリス英語": "en-US_BroadbandModel",
            "中国語": "zh-CN_BroadbandModel"
        ]
        
        // 音声認識の実行
        speechToText.recognize(audio: speechUrl, settings: settings, model: languages[languageKey],
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
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print("Cell: \(indexPath.row) を削除")
        
        // DocumentDirectoryのPathを設定
        let documentPath = FileManager.documentDir
        
        // 削除するファイル名を設定
        let fileName = appDelegate.videos[indexPath.row].name
        
        // ファイルのPathを設定
        let filePath: String = documentPath + "/" + fileName
        
        // MP4とM4aのファイルを削除
        do {
            try FileManager.default.removeItem(atPath: filePath + ".mp4")
            try FileManager.default.removeItem(atPath: filePath + ".m4a")
        } catch {
            print("\(fileName)は既に削除済み")
        }
        
        // 先にデータを更新する
        appDelegate.videos.remove(at: indexPath.row)
        
        // それからテーブルの更新
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        tableView.reloadData()
    }
    
    
    /* 移動可能なCellを設定 */
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    /* Cellの個数を指定 */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.videos.count
    }
    
    /* Cellに値を設定 */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellの指定
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "TableCell", for: indexPath)
        
        // Cellのサムネイル画像を設定
        let imageView = cell.viewWithTag(1) as! UIImageView
        imageView.image = appDelegate.videos[indexPath.row].image
        imageView.contentMode = .scaleAspectFit
        
        // Cellの説明を設定
        let label = cell.viewWithTag(2) as! UILabel
        label.text = appDelegate.videos[indexPath.row].label
        label.font = MDCTypography.captionFont()
        label.alpha = MDCTypography.captionFontOpacity()

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
        print(appDelegate.videos[indexPath.row].name)
        print("<--- VideoName")
        
        // 選択されたセルの動画情報をprepareメソッドに渡すためにselectedVideoInfoに一時保管
        selectedVideoInfo = appDelegate.videos[indexPath.row]
        
        // SubViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toSubViewController", sender: nil)
        
        // Cellの選択状態を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer){
        
    }
    @IBAction func labelEditButton(_ sender: UIButton) {
        print("編集")
        
        textField.isHidden = false
        editCompleteButton.isHidden = false
        editCancelButton.isHidden = false
        
     //押された位置でcellのpathを取得
        let btn = sender
        let cell = btn.superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)?.row
        
        

        index = indexPath
        
        
        // サイズ設定
        textField.frame.size.width = self.view.frame.width * 2 / 3
        textField.frame.size.height = 48
        
        // 位置設定
        textField.center.x = self.view.center.x
        textField.center.y = 240

        // Delegate を設定
        textField.layoutDelegate = self as? MDCMultilineTextInputLayoutDelegate
                
                // プレースホルダー
                textField.placeholder = "動画タイトルの入力"
                

                
                // テキストを全消去するボタンを表示
                textField.clearButtonMode = .always
        
                selectImageButton.isEnabled = false
                self.tableView.allowsSelection = false
    }
    /*@objc func longPressGesture(sender : UILongPressGestureRecognizer) {
        print("Long Pressed.")
        
     
    }
 */
    
    
    /* Segueの準備 */
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            /*
            if let cell = sender as? UITableViewCell {
                print("prepare")
                let indexPath = self.tableView.indexPath(for: cell)!
                let subVC = segue.destination as! SubViewController
                subVC.receivedVideoInfo = self.appDelegate.videos[indexPath.row]
            }
            */
            
            // 遷移先のViewControllerを設定
            let subVC = segue.destination as! SubViewController
            
            // 値の受け渡し
            subVC.receivedVideoInfo = selectedVideoInfo
            subVC.sourceLanguageKey = self.languageKey
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
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
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
extension MainViewController: TableViewReorderDelegate{
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath,  to destinationIndexPath: IndexPath) {
        
        // Update data model
        let sourceVideo = sourceIndexPath.row
        let destinationVideo = destinationIndexPath.row
        
        if sourceVideo >= 0 && sourceVideo < appDelegate.videos.count && destinationVideo >= 0 && destinationVideo < appDelegate.videos.count{
            let video = appDelegate.videos[sourceVideo]
            
            appDelegate.videos.remove(at: sourceVideo)
            appDelegate.videos.insert(video, at: destinationVideo)
            
        }
    }
}
