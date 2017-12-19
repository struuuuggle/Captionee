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

class SubViewController: UIViewController, ItemDelegate {
    
    var receivedVideoInfo: VideoInfo!
    
    var player: AVPlayer!
    var timeSlider: MDCSlider!
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
            
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    var duration: Double {
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.asset.duration)
    }
    
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var translation: UILabel!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        // DocumentDirectoryのPath
        let documentPath: String = FileManager.documentDir
        
        // 動画のURL
        let url = URL(fileURLWithPath: documentPath + "/" + receivedVideoInfo.name + ".mp4")
        
        // AVPlayerを生成
        player = AVPlayer(url: url)
        
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
        playerViewController.view.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        playerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // TimeObserverを設定
        addPeriodicTimeObserver()
        
        // 字幕のLabelのサイズを設定
        caption.text = ""
        caption.numberOfLines = 0
        view.addSubview(caption)
        
        // 字幕のLabelの制約を設定
        caption.translatesAutoresizingMaskIntoConstraints = false
        caption.topAnchor.constraint(equalTo: playerViewController.view.bottomAnchor, constant: 20).isActive = true
        caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        caption.bottomAnchor.constraint(equalTo: playButton.topAnchor, constant: -20)
        
        // ボタンをクリックしたときに呼び出すメソッドを指定
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)

        // スライダーの設定
        timeSlider = MDCSlider()
        timeSlider.minimumValue = 0.0
        timeSlider.maximumValue = CGFloat(duration)
        timeSlider.isContinuous = true
        timeSlider.isThumbHollowAtStart = false
        timeSlider.color = MDCPalette.orange.tint500
        view.addSubview(timeSlider)
        
        // スライダーの値が変わったときに呼び出すメソッドを指定
        timeSlider.addTarget(self, action: #selector(timeSliderChanged), for: .valueChanged)
        timeSlider.addTarget(self, action: #selector(timeSliderTapped), for: .touchUpInside)
        
        // スライダーの制約を設定
        timeSlider.translatesAutoresizingMaskIntoConstraints = false
        timeSlider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: 10).isActive = true
        timeSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        timeSlider.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
        timeSlider.heightAnchor.constraint(equalToConstant: 10).isActive = true
        
        // NavigationBarの右側にtranslateButtonを設置
        let translateButton = UIBarButtonItem(image: UIImage(named: "Horizontal"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(itemButtonTapped))
        navigationItem.rightBarButtonItem = translateButton
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
        // ItemViewControllerを作成
        let viewController: ItemViewController = ItemViewController()
        // ItemViewControllerのdelegateを設定
        viewController.delegate = self
        
        // BottomSheetを作成
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        // BottomSheetを表示
        present(bottomSheet, animated: true, completion: nil)
    }
    
    /* 編集ボタンが押されたとき */
    func editButtonTapped() {
        print("編集")
    }
    
    /* 翻訳ボタンが押されたとき */
    func translateButtonTapped() {
        print("翻訳")
        
        let queue = DispatchQueue.global(qos: .default)
        let translator = Translation("ja", "en")
                
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
    
    /* スライダーの値が変わったとき */
    @objc func timeSliderChanged(sender: MDCSlider) {
        print("スライダーの値が変わった")
        
        // 動画の時間をスライダーの値にする
        currentTime = Double(sender.value)
    }
    
    /* スライダーがタップされたとき */
    @objc func timeSliderTapped(sender: MDCSlider) {
        print("スライダーがタップされた")
        
        if isPlaying {
            pause()
            currentTime = Double(sender.value)
            play()
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
            
            // Sliderの値を変える
            wself.timeSlider.setValue(CGFloat(wself.currentTime), animated: true)
            print(wself.currentTime)
            
            // 字幕を適切なタイミングで表示
            if let captions = wself.receivedVideoInfo.caption {
                for caption in captions.sentences {
                    if self!.currentTime >= caption.startTime && self!.currentTime <= caption.endTime {
                        self?.caption.text = caption.foreign + "."
                        break
                    }
                }
            } else {
                wself.caption.text = "Caption is nil."
            }
        }
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
        
        // 動画の再生を止める
        player.pause()
        
        // TimeObserverを廃棄
        timeObserverToken = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("ViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("ViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
    }
}
