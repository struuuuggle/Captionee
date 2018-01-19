//
//  SubViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/05.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import AVKit
import MaterialComponents
import Material

class SubViewController: UIViewController, ItemDelegate {
    
    var receivedVideoInfo: VideoInfo!
    var player: AVPlayer!
    var timeObserverToken: Any!
    var isPlaying = false
    
    var isFinished: Bool {
        return currentTime == duration
    }
    
    var currentTime: Double {
        get {
            return player.currentTime().seconds
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1000)
            
            print(newValue)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            elapsedTimeLabel.text = timeToString(newValue)
            remainingTimeLabel.text = "-" + timeToString(duration-newValue)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.asset.duration)
    }
    
    // 翻訳元と翻訳先の言語
    var sourceLanguageKey: String!
    var targetLanguageKey = "English" {
        didSet {
            print("targetLanguage is \(targetLanguageKey).")
            
            // 字幕を翻訳
            if self.sourceLanguageKey != self.targetLanguageKey {
                translation()
            } else {
                if let captions = receivedVideoInfo.caption {
                    for caption in captions.sentences {
                        caption.foreign = caption.original
                    }
                }
            }
        }
    }
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var timeSlider = MDCSlider()
    var textField = MDCMultilineTextField()
    var editCompleteButton = MDCRaisedButton()
    var editCancelButton = MDCRaisedButton()
    var caption = UILabel()
    var playButton = UIButton()
    var stepper = UIStepper()
    var elapsedTimeLabel = UILabel()
    var remainingTimeLabel = UILabel()
    let itemButton = IconButton(image: Icon.moreHorizontal, tintColor: UIColor.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SubViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        view.backgroundColor = UIColor.white
        
        // DocumentDirectoryのPath
        let documentPath: String = Utility.documentDir
        
        // 動画のURL
        let url = URL(fileURLWithPath: documentPath + "/" + receivedVideoInfo.name + ".mp4")
        
        // AVPlayerを生成
        player = AVPlayer(url: url)
        if Utility.userDefault.bool(forKey: "SupportMode") {
            player.volume = 0.0
        }
        
        // 動画の時間を初期化
        currentTime = 0.0
        
        // AVPlayerViewControllerの設定
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        addChildViewController(playerViewController)
        view.addSubview(playerViewController.view)
        
        // AVPlayerViewControllerの制約を設定
        playerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        playerViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playerViewController.view.heightAnchor.constraint(equalToConstant: view.frame.width*9/16).isActive = true
        
        // TimeObserverを設定
        addPeriodicTimeObserver()
        
        // 字幕のLabelの設定
        caption.text = ""
        caption.font = MDCTypography.body1Font()
        caption.numberOfLines = 0
        caption.lineBreakMode = .byWordWrapping
        view.addSubview(caption)
        
        // 字幕のLabelの制約を設定
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.topAnchor.constraint(equalTo: playerViewController.view.bottomAnchor, constant: 20).isActive = true
        caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        caption.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -48)
        
        playButton.setImage(UIImage(named: "Play"), for: .normal)
        // ボタンをクリックしたときに呼び出すメソッドを指定
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        view.addSubview(playButton)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        // 経過時間Labelの設定
        elapsedTimeLabel.text = "0:00"
        elapsedTimeLabel.font = MDCTypography.captionFont()
        elapsedTimeLabel.textAlignment = .right
        view.addSubview(elapsedTimeLabel)
        
        // 経過時間Labelの制約を設定
        elapsedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        elapsedTimeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        elapsedTimeLabel.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10).isActive = true
        elapsedTimeLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        elapsedTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true

        // スライダーの設定
        timeSlider.minimumValue = 0.0
        timeSlider.maximumValue = CGFloat(duration)
        timeSlider.isContinuous = true
        timeSlider.isThumbHollowAtStart = false
        timeSlider.color = MDCPalette.orange.tint500
        timeSlider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderTapped), for: .touchUpInside)
        view.addSubview(timeSlider)
        
        // スライダーの制約を設定
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.leadingAnchor.constraint(equalTo: elapsedTimeLabel.trailingAnchor, constant: 5).isActive = true
        timeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -55).isActive = true
        timeSlider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // 残り時間Labelの設定
        remainingTimeLabel.text = "-" + timeToString(duration)
        remainingTimeLabel.font = MDCTypography.captionFont()
        view.addSubview(remainingTimeLabel)
        
        // 残り時間Labelの制約を設定
        remainingTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingTimeLabel.leadingAnchor.constraint(equalTo: timeSlider.trailingAnchor, constant: 5).isActive = true
        remainingTimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        remainingTimeLabel.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        remainingTimeLabel.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // TextFieldの設定
        textField.isHidden = true
        view.addSubview(textField)
        
        // TextFieldの制約を設定
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.topAnchor.constraint(equalTo: playerViewController.view.bottomAnchor, constant: 20).isActive = true
        textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        textField.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -48)
        
        // 編集完了ボタンの設定
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
        
        // Stepperの設定
        stepper.minimumValue = 10
        stepper.maximumValue = 25
        stepper.value = Double(caption.font.pointSize)
        stepper.stepValue = 1
        stepper.autorepeat = true
        stepper.isContinuous = true
        stepper.tintColor = MDCPalette.orange.tint500
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        view.addSubview(stepper)
        
        // Stepperの制約を設定
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.topAnchor.constraint(equalTo: playButton.topAnchor, constant: -48).isActive = true
        stepper.leadingAnchor.constraint(equalTo: caption.leadingAnchor).isActive = true
        stepper.widthAnchor.constraint(equalToConstant: 6).isActive = true
        stepper.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        // NavigationBarの右側にItemButtonを設置
        itemButton.addTarget(self, action: #selector(itemButtonTapped), for: .touchUpInside)
        navigationItem.rightViews = [itemButton]
        
        navigationItem.backButton.tintColor = UIColor.white
        
        sourceLanguageKey = receivedVideoInfo.language
        print("sourceLanguage is \(sourceLanguageKey)")
        print("targetLanguage is \(targetLanguageKey)")
    }
    
    /* 再生・一時停止ボタンが押されたとき */
    @objc func playButtonTapped(sender: UIButton) {
        if isPlaying {
            // 一時停止
            pause()
        } else {
            // 動画が終わっていたら最初に戻す
            if isFinished {
                currentTime = 0.0
            }
            
            // 再生
            play()
        }
    }
    
    /* アイテムボタンが押されたとき */
    @objc func itemButtonTapped(sender: UIButton) {
        print("Item Button Tapped")
        
        // ItemViewControllerを作成
        let viewController: ItemViewController = ItemViewController()
        // ItemViewControllerのdelegateを設定
        viewController.delegate = self
        
        // BottomSheetを作成
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        // BottomSheetを表示
        present(bottomSheet, animated: true, completion: nil)
    }
    
    /* 「字幕を編集」ボタンが押されたとき */
    func editButtonTapped() {
        print("編集")
        
        caption.isHidden = true
        stepper.isHidden = true
        textField.isHidden = false
        
        textField.text = caption.text
        editCompleteButton.isHidden = false
        editCancelButton.isHidden = false
        
        pause()
        
        // キーボードを表示する(仮)
        // TODO: BottomSheetが完全に隠れてからキーボードの表示
        textField.becomeFirstResponder()
    }
    
    /* 字幕の編集が完了されたとき */
    @objc func editCompleteButtonTapped() {
        print("編集完了")
        
        view.endEditing(true)
        
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        caption.isHidden = false
        
        if let captions = receivedVideoInfo.caption {
            for caption in captions.sentences {
                if currentTime >= caption.startTime && currentTime <= caption.endTime {
                    caption.foreign = textField.text
                }
            }
        }
        caption.text = textField.text
        
        stepper.isHidden = false
    }
    
    /* 字幕の編集がキャンセルされたとき */
    @objc func editCancelButtonTapped() {
        print("編集キャンセル")
        
        view.endEditing(true)
        
        textField.isHidden = true
        editCompleteButton.isHidden = true
        editCancelButton.isHidden = true
        caption.isHidden = false
        stepper.isHidden = false
    }
    
    /* 「字幕を翻訳」ボタンが押されたとき */
    func translateButtonTapped() {
        print("翻訳ボタン")
        
        pause()
        
        selectLanguage()
    }
    
    /* 翻訳言語の選択用ダイアログを表示する */
    func selectLanguage() {
        // AlertControllerを作成
        let alert = MDCAlertController(title: "言語選択", message: "翻訳する言語を選択してください")
        
        // AlertAction用ハンドラ
        let handler: MDCActionHandler = { (action) -> Void in
            self.targetLanguageKey = action.title!
        }
        
        // AlertActionを作成
        let english = MDCAlertAction(title: "English", handler: handler)
        let korean = MDCAlertAction(title: "한국어", handler: handler)
        let chinese = MDCAlertAction(title: "中文", handler: handler)
        let japanese = MDCAlertAction(title: "日本語", handler: handler)
        
        // 選択肢をAlertに追加
        // ダイアログ上では、先に追加したAlertActionほど下に表示される
        alert.addAction(english)
        alert.addAction(korean)
        alert.addAction(chinese)
        alert.addAction(japanese)
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    /* 字幕を翻訳する */
    func translation() {
        print("翻訳")

        // サポートされている翻訳言語の辞書
        let languages = [
            "日本語": "ja",
            "中文": "zh-CN",
            "한국어": "ko",
            "English": "en",
        ]
        
        let queue = DispatchQueue.global(qos: .default)
        let translator = Translation(languages[sourceLanguageKey]!, languages[targetLanguageKey]!)
        
        if let captions = receivedVideoInfo.caption {
            for caption in captions.sentences {
                // サブスレッドで処理
                queue.async {
                    // データの取得
                    caption.foreign = translator.translate(caption.original)
                    // メインスレッドで処理
                    DispatchQueue.main.async {
                        // 取得した翻訳結果を表示
                        print("---> Translation")
                        print(caption.foreign)
                        print("<--- Translation")
                    }
                }
            }
        } else {
            print("Translation is nil.")
        }
    }
    
    /* 「チュートリアル」ボタンが押されたとき */
    func tutorialButtonTapped() {
        print("チュートリアル")
        
        pause()
        
        tutorial1()
        
        /* 将来的にこうしたい
        Tutorial.add(playButton, "再生ボタン", "このボタンを押すことで、動画を再生・一時停止することができます")
        Tutorial.add(caption, "字幕", "ここに字幕が表示されます")
        Tutorial.add(timeSlider, "スライダー", "このスライダーを操作することで、動画の再生をコントロールします")
        Tutorial.show(self)
        */
    }
    
    /* チュートリアル1 */
    func tutorial1() {
        let completion1 = { (accepted: Bool) in
            if accepted {
                print("Accepted")
            } else {
                print("Unaccepted")
            }
            
            self.tutorial2()
        }
        let tutorial1 = Tutorial.create(playButton, "再生ボタン", "このボタンを押すことで、動画を再生・一時停止することができます", completion1)
        present(tutorial1, animated: true, completion: nil)
    }
    
    /* チュートリアル2 */
    func tutorial2() {
        let completion2 = { (accepted: Bool) in
            if accepted {
                print("Accepted")
            } else {
                print("Unaccepted")
            }
            
            self.tutorial3()
        }
        let tutorial2 = Tutorial.create(caption, "字幕", "ここに字幕が表示されます", completion2)
        present(tutorial2, animated: true, completion: nil)
    }
    
    /* チュートリアル3 */
    func tutorial3() {
        let completion3 = { (accepted: Bool) in
            if accepted {
                print("Accepted")
            } else {
                print("Unaccepted")
            }
            
            self.tutorial4()
        }
        let tutorial3 = Tutorial.create(timeSlider, "スライダー", "このスライダーを操作することで、動画の再生をコントロールします", completion3)
        present(tutorial3, animated: true, completion: nil)
    }
    
    /* チュートリアル4 */
    func tutorial4() {
        let completion4 = { (accepted: Bool) in
            if accepted {
                print("Accepted")
            } else {
                print("Unaccepted")
            }
            
            self.itemButton.tintColor = UIColor.white
        }
        itemButton.tintColor = UIColor.black
        let tutorial4 = Tutorial.create(itemButton, "機能ボタン", "字幕の編集と翻訳はこのボタンからできます", completion4)
        present(tutorial4, animated: true, completion: nil)
    }
    
    /* 動画を再生する */
    func play() {
        print("再生")
        player.play()
        isPlaying = true
        
        // ボタンの画像をPauseに変える
        playButton.setImage(UIImage(named: "Pause"), for: .normal)
    }
    
    /* 動画を一時停止する */
    func pause() {
        print("一時停止")
        player.pause()
        isPlaying = false
        
        // ボタンの画像をPlayに変える
        playButton.setImage(UIImage(named: "Play"), for: .normal)
    }
    
    /* Stepperの値が変わったとき */
    @objc func stepperValueChanged(sender: UIStepper) {
        caption.font = MDCTypography.body1Font().withSize(CGFloat(sender.value))
    }
    
    /* スライダーの値が変わったとき */
    @objc func timeSliderChanged(sender: MDCSlider) {
        print("スライダーの値が変わった")
        
        player.pause()
        
        // 動画の時間をスライダーの値にする
        currentTime = Double(sender.value)
    }
    
    /* スライダーがタップされたとき */
    @objc func timeSliderTapped(sender: MDCSlider) {
        print("スライダーがタップされた")
        
        if isPlaying {
            currentTime = Double(sender.value)
            player.play()
        } else {
            currentTime = Double(sender.value)
        }
    }
    
    /* 一定時間ごとに動画の再生状態を監視する */
    func addPeriodicTimeObserver() {
        // 監視の時間間隔
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        // メインスレッド
        let mainQueue = DispatchQueue.main
        
        // TimeObserverを生成
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            guard let wself = self else { return }
            
            // 動画の再生が終わっているとき
            if wself.isFinished {
                // 一時停止
                wself.pause()
            }
            
            print(wself.currentTime)
            
            // Sliderの値を変える
            wself.timeSlider.setValue(CGFloat(wself.currentTime), animated: true)
            
            wself.elapsedTimeLabel.text = wself.timeToString(wself.currentTime)
            wself.remainingTimeLabel.text = "-" + wself.timeToString(wself.duration-wself.currentTime)
            
            // 字幕を適切なタイミングで表示
            if let captions = wself.receivedVideoInfo.caption {
                for caption in captions.sentences {
                    if wself.currentTime >= caption.startTime && wself.currentTime <= caption.endTime {
                        wself.caption.text = caption.foreign
                        return
                    }
                }
                
                wself.caption.text = ""
            } else {
                wself.caption.text = "Caption is nil."
            }
        }
    }
    
    // Doubleを時間形式のStringに変換
    func timeToString(_ time: Double) -> String {
        var totalSeconds = Int(time)
        let hours = totalSeconds / 3600
        totalSeconds %= 3600
        let minutes = totalSeconds / 60
        totalSeconds %= 60
        let seconds = totalSeconds
        
        var timeString = ""
        
        if hours > 0 {
            timeString += String(hours) + ":"
            
            if minutes < 10 {
                timeString += "0"
            }
        }
        
        timeString += String(minutes) + ":"
        
        if seconds < 10 {
            timeString += "0"
        }
        timeString += String(seconds)
        
        return timeString
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Tapped!")
        
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SubViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SubViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SubViewController/viewWillDisappear/別の画面に遷移する直前")
        
        // 動画の再生を止める
        player.pause()
        
        // TimeObserverを廃棄
        timeObserverToken = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SubViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("SubViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
    }
}
