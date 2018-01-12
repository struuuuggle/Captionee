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
import SafariServices
import SpeechToTextV1
import DZNEmptyDataSet
import MaterialComponents
import SwiftReorder
import Alamofire
import DKImagePickerController

/* メイン画面のController */
class MainViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SideMenuDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    var window: UIWindow?
    var speechToText: SpeechToText!
    var selectedVideoInfo: VideoInfo?
    var index: Int!
    var textField: MDCTextField!
    var editCompleteButton: MDCRaisedButton!
    var editCancelButton: MDCRaisedButton!
    let sideMenuController = SideMenuController()
    var fabOffset: CGFloat = 0
    var removedVideoInfo: VideoInfo?
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var languageKey = "日本語"
    
    @IBOutlet weak var tableView: UITableView!
    var selectImageButton: MDCFloatingButton!
    
    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MainViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
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
        
        tableView.reorder.delegate = self
        
        sideMenuController.delegate = self
        
        // TableViewのSeparatorを消す
        tableView.tableFooterView = UIView(frame: .zero);
        
        // TableViewの背景色を設定
        tableView.backgroundColor = MDCPalette.grey.tint100
        
        // SpeechToTextのUsernameとPasswordを設定
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        
        // エッジのドラッグ認識
        let edgePanGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(edgePanGesture))
        edgePanGestureRecognizer.edges = .left
        view.addGestureRecognizer(edgePanGestureRecognizer)
        
        // TextFieldの設定
        textField = MDCTextField()
        textField.isHidden = true
        view.addSubview(textField)
        
        // TextFieldの制約を設定
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textField.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        textField.widthAnchor.constraint(equalToConstant: view.frame.width*2/3).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        // StatusBarの高さ
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        // NavigationBarの高さ
        let navigationBarHeight = navigationController?.navigationBar.frame.height
        
        // アップロードボタンのサイズ
        let fabSize: CGFloat = 56
        
        // アップロードボタンの設定
        selectImageButton = MDCFloatingButton(type: .roundedRect)
        selectImageButton.frame = CGRect(x: UIScreen.main.bounds.width-fabSize-16,
                                         y: UIScreen.main.bounds.height-statusBarHeight-navigationBarHeight!-fabSize-16,
                                         width: fabSize,
                                         height: fabSize)
        selectImageButton.setImage(UIImage(named: "Add"), for: .normal)
        selectImageButton.tintColor = UIColor.white
        selectImageButton.backgroundColor = MDCPalette.yellow.tint600
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        view.addSubview(selectImageButton)
        
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
        
        navigationController?.view.addSubview(sideMenuController.view)
        
        let manager = MDCOverlayObserver(for: nil)
        manager?.addTarget(self, action: #selector(handleOverlayTransition))
        
        //tableViewの更新
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.blue
        let attstr: NSAttributedString? = NSMutableAttributedString(string: NSLocalizedString("Loading", comment: ""), attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 13.0)])
        refreshControl.attributedTitle = attstr

        refreshControl.addTarget(self, action: #selector(MainViewController.refreshControlValueChanged(sender:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        print("テーブルを下に引っ張った時に呼ばれる")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            sender.endRefreshing()
        })
        tableView.reloadData()
    }
    
    /* MenuButtonが押されたとき */
    @objc func menuButtonTapped(_ sender: UIBarButtonItem) {
        print("Menu button tapped.")
        
        sideMenuController.open()
    }
    
    /* 画面の左端がドラッグされたとき */
    @objc func edgePanGesture(sender: UIScreenEdgePanGestureRecognizer){
        sideMenuController.dragging(sender.state, sender.translation(in: view))
        
        //移動量をリセットする。
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    /* 編集が完了されたとき */
    @objc func editCompleteButtonTapped() {
        view.endEditing(true)
        
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        
        appDelegate.videos[index].label = textField.text!
        
        textField.text = ""
        selectImageButton.isEnabled = true
        tableView.reloadData()
        tableView.allowsSelection = true
    }
    
    /* 編集がキャンセルされたとき */
    @objc func editCancelButtonTapped() {
        view.endEditing(true)
        
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        
        textField.text = ""
        selectImageButton.isEnabled = true
        tableView.allowsSelection = true
    }
    
    /* PhotoLibraryから動画を選択する */
    @objc func selectImage(_ sender: Any) {
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
        let imagePickerController = DKImagePickerController()
        imagePickerController.autoCloseOnSingleSelect = false
        imagePickerController.singleSelect = true
        imagePickerController.showsCancelButton = true
        imagePickerController.showsEmptyAlbums = false
        imagePickerController.sourceType = .both
        imagePickerController.assetType = .allVideos
        imagePickerController.didSelectAssets = { (assets: [DKAsset]) in
            print("動画が選択された")
            
            // 選択された動画を1つずつ処理
            for asset in assets {
                // DKAssetからAVAssetを取り出す
                asset.fetchAVAsset(true, options: nil, completeBlock: { (video, info) in
                    // 動画の名前
                    let name = self.getCurrentTime()
                    // 動画のサムネイル
                    let image = self.previewImageFromVideo(video!)!
                    // 動画のラベル
                    let label = self.convertFormat(name)
                    
                    // 動画のパス
                    let path = Utility.documentDir + "/" + name + ".mp4"
                    
                    // Documentに動画を保存
                    asset.writeAVToFile(path, presetName: AVAssetExportPresetPassthrough, completeBlock: {(success) in print("Success!")
                        
                        // 動画をサーバにアップロードする
                        // 長い動画をアップロードするときは極力ここをコメントアウトしてね
                        // self.uploadFileToServer(name)
                    })
                    
                    // メインスレッドで実行
                    DispatchQueue.main.async {
                        // 動画の言語を選択させる
                        self.selectLanguage()
                        
                        // TableViewにCellを追加
                        self.appDelegate.videos.append(VideoInfo(name, image, label))
                        
                        // TableViewを更新
                        self.tableView.reloadData()
                    }
                })
            }
        }
        
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
    
    /* 動画からサムネイルを生成する */
    func previewImageFromVideo(_ asset: AVAsset) -> UIImage? {
        print("動画からサムネイルを生成")
        
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
    
    /* 動画の言語の選択用ダイアログを表示する */
    func selectLanguage() {
        // AlertControllerを作成
        let alert = MDCAlertController(title: "言語選択", message: "動画の言語を選択してください")
        
        // AlertAction用ハンドラ
        let handler: MDCActionHandler = { (action) -> Void in
            self.appDelegate.videos[self.appDelegate.videos.count-1].language = action.title!
            self.languageKey = action.title!
        }
        
        // AlertActionを作成
        let chinese = MDCAlertAction(title: "中文", handler: handler)
        let english = MDCAlertAction(title: "English", handler: handler)
        let japanese = MDCAlertAction(title: "日本語", handler: handler)
        
        // 選択肢をAlertに追加
        // ダイアログ上では、以下のコードで先に追加したAlertActionほど下に表示される
        alert.addAction(chinese)
        alert.addAction(english)
        alert.addAction(japanese)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    /* ファイルをサーバにアップロードする */
    func uploadFileToServer(_ fileName: String) {
        print("ファイルをサーバにアップロード")
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                // ファイルのパス
                let path = Utility.documentDir + "/" + fileName + ".mp4"
                let url = URL(fileURLWithPath: path)
                
                // サーバサイドでは、withName は $_FILES["uploaded_file"]["tmp_name"] のように使われる
                multipartFormData.append(url, withName: "uploaded_file", fileName: "input.mp4", mimeType: "video/mp4")
            },
            to: "http://captionee.ddns.net/encoder/encoder.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    print("Upload success!")
                    
                    upload.responseString { response in
                        debugPrint(response)
                    }
                    
                    self.downloadFileFromServer(fileName)
                case .failure(let encodingError):
                    print("Upload failure...")
                    print(encodingError)
                }
            }
        )
    }
    
    /* ファイルをサーバからダウンロードする */
    func downloadFileFromServer(_ fileName: String) {
        print("ファイルをサーバからダウンロード")
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = URL(fileURLWithPath: Utility.documentDir)
            let fileURL = documentsURL.appendingPathComponent("\(fileName).wav")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download("http://captionee.ddns.net/encoder/Output/output.wav", to: destination).response { response in
            if response.error == nil {
                print("Download success!")
                debugPrint(response)
                
                if let resultURL = response.destinationURL {
                    self.generateCaption(resultURL)
                } else {
                    print("Result url is nil")
                }
            } else {
                print("Download failure...")
                print(response.error!)
            }
        }
    }
    
    /* 字幕を生成する */
    func generateCaption(_ speechUrl: URL) {
        print("字幕を生成")
        
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
            "中文": "zh-CN_BroadbandModel",
            "English": "en-US_BroadbandModel",
        ]
        
        // 音声認識の実行
        speechToText.recognize(audio: speechUrl, settings: settings, model: languages[languageKey],
                               customizationID: nil, learningOptOut: true, failure: failure, success: success)
    }
    
    /* 動画のアップロードに成功したとき */
    func success() {
        print("Speech recognition success!")
    }
    
    /* 動画のアップロードに失敗したとき */
    func failure() {
        print("Speech recognition failure...")
    }
    
    /* 設定ボタンが押されたとき */
    func settingsButtonTapped() {
        print("設定")
        
        let settingsViewController = SettingsViewController()
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    /* チュートリアルボタンが押されたとき */
    func tutorialButtonTapped() {
        print("チュートリアル")
        
        let completion = { (accepted: Bool) in
            if accepted {
                print("Accepted")
            } else {
                print("Unaccepted")
            }
        }
        let tutorial = Tutorial.create(selectImageButton, "チュートリアル", "チュートリアルを再生します。", completion)
        present(tutorial, animated: true, completion: nil)
    }
    
    /* フィードバックボタンが押されたとき */
    func feedbackButtonTapped() {
        print("フィードバック")
        
        // AlertControllerを作成
        let alert = MDCAlertController(title: "どんなエラーが起きましたか？",
                                       message: "今起きた問題について簡単に説明してください。後ほど詳しいことをお聞きします。")
        
        // AlertActionを作成
        let send = MDCAlertAction(title: "SEND", handler: { (action) -> Void in
            print("フィードバックを送信")
        })
        let cancel = MDCAlertAction(title: "CANCEL", handler: nil)
        
        // 選択肢をAlertに追加
        alert.addAction(send)
        alert.addAction(cancel)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    /* ヘルプボタンが押されたとき */
    func helpButtonTapped() {
        print("ヘルプ")
        
        let url = URL(string: "https://struuuuggle.github.io/Captionee/")
        if let url = url {
            print("Open safari success!")
            
            let safariViewController = SFSafariViewController(url: url)
            present(safariViewController, animated: true, completion: nil)
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
        
        /*
        // DocumentDirectoryのPathを設定
        let documentPath = Utility.documentDir
        
        // 削除するファイル名を設定
        let fileName = appDelegate.videos[indexPath.row].name
        
        // ファイルのPathを設定
        let filePath: String = documentPath + "/" + fileName
        
        // MP4とM4aのファイルを削除
        do {
            try FileManager.default.removeItem(atPath: filePath + ".mp4")
            try FileManager.default.removeItem(atPath: filePath + ".wav")
        } catch {
            print("\(fileName)は既に削除済み")
        }
        */
        
        // 削除されたセルを一時退避
        removedVideoInfo = appDelegate.videos[indexPath.row]
        
        // セルを削除
        appDelegate.videos.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // 元に戻すボタンを生成
        let action = MDCSnackbarMessageAction()
        let actionHandler = { () in
            // セルを戻す
            self.appDelegate.videos.insert(self.removedVideoInfo!, at: indexPath.row)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        action.handler = actionHandler
        action.title = "元に戻す"
        
        // SnackBarを生成
        let message = MDCSnackbarMessage(text: "ゴミ箱に移動しました")
        message.action = action
        message.buttonTextColor = MDCPalette.indigo.tint200
        
        // SnackBarを表示
        MDCSnackbarManager.show(message)
    }
    
    /* SnackBarが表示・非表示するときに呼ばれる */
    @objc func handleOverlayTransition(transition: MDCOverlayTransitioning) {
        if fabOffset == 0 {
            print("SnackBarを表示")
        } else {
            print("SnackBarを非表示")
        }
        
        let bounds = view.bounds
        let coveredRect = transition.compositeFrame(in: view)
        
        let boundedRect = bounds.intersection(coveredRect)
        
        var fabVerticalShift: CGFloat = 0
        var distanceFromBottom: CGFloat = 0
        
        if !boundedRect.isEmpty {
            distanceFromBottom = bounds.maxY - boundedRect.minY
        }
        
        fabVerticalShift = fabOffset - distanceFromBottom
        fabOffset = distanceFromBottom
        
        transition.animate(alongsideTransition: {
            self.selectImageButton.center = CGPoint(x: self.selectImageButton.center.x, y: self.selectImageButton.center.y+fabVerticalShift)
        })
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
                
        // プレースホルダー
        textField.placeholder = "動画タイトルの入力"
        
        textField.text = appDelegate.videos[index].label
        
        // テキストを全消去するボタンを表示
        textField.clearButtonMode = .always
        
        selectImageButton.isEnabled = false
        tableView.allowsSelection = false
    }
    
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
        print("MainViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("MainViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("MainViewController/viewWillDisappear/別の画面に遷移する直前")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("MainViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("MainViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
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

extension MainViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath,  to destinationIndexPath: IndexPath) {
        // Update data model
        let sourceVideo = sourceIndexPath.row
        let destinationVideo = destinationIndexPath.row
        
        if sourceVideo >= 0 && sourceVideo < appDelegate.videos.count && destinationVideo >= 0 && destinationVideo < appDelegate.videos.count {
            let video = appDelegate.videos[sourceVideo]
            
            appDelegate.videos.remove(at: sourceVideo)
            appDelegate.videos.insert(video, at: destinationVideo)
        }
    }
}
