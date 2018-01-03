//
//  AppDelegate.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/09/15.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents
import Presentation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var themeColor = "Orange"
    let color = ["Red": MDCPalette.red.tint700, "Orange": MDCPalette.orange.tint500,
                 "Yellow": MDCPalette.yellow.tint500, "Green": MDCPalette.green.tint500,
                 "Blue": MDCPalette.blue.tint500]
    var videos = [VideoInfo]()
    let userDefault = UserDefaults.standard
    
    private lazy var navigationController: UINavigationController = { [unowned self] in
        let controller = UINavigationController(rootViewController: self.presentationController)
        // ウォークスルーの背景色をここで設定
        controller.view.backgroundColor = color["Blue"] // colorは要変更
        // NavigationBarを表示しない
        controller.navigationBar.isHidden = true
        
        return controller
    }()
    
    private lazy var presentationController: PresentationController = {
        let controller = PresentationController(pages: [])
        controller.setNavigationTitle = false
        
        return controller
    }()
    
    private lazy var leftButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "Previous page",
            style: .plain,
            target: self.presentationController,
            action: #selector(PresentationController.moveBack)
        )
        
        button.setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor: UIColor.white],
            for: .normal
        )
        
        return button
    }()
    
    private lazy var rightButton: UIBarButtonItem = { [unowned self] in
        let button = UIBarButtonItem(
            title: "Next page",
            style: .plain,
            target: self.presentationController,
            action: #selector(PresentationController.moveForward)
        )
        
        button.setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor: UIColor.white],
            for: .normal
        )
        
        return button
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // NavigationBarの設定
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = color[themeColor]
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: MDCTypography.titleFont()
        ]
        UINavigationBar.appearance().isTranslucent = false
        
        // 起動時間延長
        sleep(1)
        
        let dict = ["firstLaunch": true]
        self.userDefault.register(defaults: dict)
        
        // 初回起動時のみに行うための処理をここに書く
        
        // ウォークスルーの実行
        playWalkthrough()
    
        // UserDefaultに保存されたデータを読み込む
        if let storedData = userDefault.object(forKey: "Videos") as? Data {
            if let unarchivedData = NSKeyedUnarchiver.unarchiveObject(with: storedData) as? [VideoInfo] {
                print("動画をロード")
                
                videos = unarchivedData
                print(videos)
            }
        }
        
        return true
    }
    
    /* アプリが初めて起動されたかを判定する */
    func isFristLaunch() -> Bool {
        return true
    }
    
    /* ウォークスルーの実行 */
    func playWalkthrough() {
        print("ウォークスルーの実行")
        
        //presentationController.navigationItem.leftBarButtonItem = leftButton
        //presentationController.navigationItem.rightBarButtonItem = rightButton
        
        /*
        configureSlides()
        configureBackground()
        */
        
        let onboarding = OnboadingViewController()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = onboarding
        self.window?.makeKeyAndVisible()
    }
    
    /* Page animations */
    private func configureSlides() {
        /*
        let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.4
        let font = UIFont(name: "ArialRoundedMTBold", size: 42.0 * ratio)!
        let color = UIColor.white
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes = [NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: color,
                          NSAttributedStringKey.paragraphStyle: paragraphStyle]
        
        let titles = ["Tutorial on how to make a profit", "Step I", "Step II", "Step III", "Thanks"].map {
            Content.content(forTitle: $0, attributes: attributes)
        }
        let texts = ["", "Collect underpants\n💭", "🎅🎅🏻🎅🏼🎅🏽🎅🏾🎅🏿", "Profit\n💸", ""].map {
            Content.content(forText: $0, attributes: attributes)
        }
        */
        
        var slides = [SlideController]()
        
        //for index in 0...4 {
            /*
            let controller = SlideController(contents: [titles[index], texts[index]])
            
            if index == 0 {
                titles[index].position.left = 0.5
                
                controller.add(animations: [
                    DissolveAnimation(content: titles[index], duration: 2.0, delay: 1.0, initial: true)
                ])
            } else {
                controller.add(animations: [
                    Content.centerTransition(forSlideContent: titles[index]),
                    Content.centerTransition(forSlideContent: texts[index])])
            }
            */
            
            let controller = SlideController()
            
            let button = MDCRaisedButton()
            button.setTitle("GET STARTED", for: .normal)
            button.setTitleFont(MDCTypography.buttonFont(), for: .normal)
            button.setTitleColor(color["Blue"], for: .normal)
            button.setBackgroundColor(UIColor.white)
            button.addTarget(self, action: #selector(getStarted), for: .touchUpInside)
            controller.view.addSubview(button)
            
            button.translatesAutoresizingMaskIntoConstraints = false
            button.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: -30).isActive = true
            button.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor).isActive = true
            button.widthAnchor.constraint(equalToConstant: 132).isActive = true
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            
            slides.append(controller)
        //}
        
        presentationController.add(slides)
    }
    
    /* Background views */
    func configureBackground() {
        let images = ["Cloud", "Cloud", "Cloud"].map { UIImageView(image: UIImage(named: $0)) }
        let content1 = Content(view: images[0], position: Position(left: -0.3, top: 0.2))
        let content2 = Content(view: images[1], position: Position(right: -0.3, top: 0.32))
//        let content3 = Content(view: images[2], position: Position(left: 0.5, top: 0.5))
        //let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        //label.text = "Get Started!"
        //let content3 = Content(view: label, position: Position(left: 0.5, top: 0.5), centered: true)
        /*
        let button = MDCRaisedButton(frame: CGRect(x: 0, y: 0, width: 132, height: 36))
        button.setTitle("GET STARTED", for: .normal)
        button.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        button.setTitleColor(color["Blue"], for: .normal)
        button.setBackgroundColor(UIColor.white)
        button.addTarget(self, action: #selector(getStarted), for: .touchUpInside)
        let content3 = Content(view: button, position: Position(left: 0.5, top: 0.87), centered: true)
        */
        
        presentationController.addToBackground([content1, content2])
        
        // 各ページのアニメーション
        
        presentationController.addAnimations([
            TransitionAnimation(content: content1, destination: Position(left: 0.2, top: 0.2)),
            TransitionAnimation(content: content2, destination: Position(right: 0.3, top: 0.32)),
//            PopAnimation(content: content3, duration: 1.0)
            ], forPage: 0)
        
        presentationController.addAnimations([
            TransitionAnimation(content: content1, destination: Position(left: 0.3, top: 0.2)),
            TransitionAnimation(content: content2, destination: Position(right: 0.4, top: 0.32)),
            ], forPage: 1)
        
        presentationController.addAnimations([
            TransitionAnimation(content: content1, destination: Position(left: 0.5, top: 0.2)),
            TransitionAnimation(content: content2, destination: Position(right: 0.5, top: 0.32)),
            ], forPage: 2)
        
        presentationController.addAnimations([
            TransitionAnimation(content: content1, destination: Position(left: 0.6, top: 0.2)),
            TransitionAnimation(content: content2, destination: Position(right: 0.7, top: 0.32)),
            ], forPage: 3)
        
        presentationController.addAnimations([
            TransitionAnimation(content: content1, destination: Position(left: 0.8, top: 0.2)),
            TransitionAnimation(content: content2, destination: Position(right: 0.9, top: 0.32)),
            //PopAnimation(content: content3, duration: 1.0)
            ], forPage: 4)
    }
    
    /* ウォークスルーを終了させる */
    @objc func getStarted() {
        print("Get Started!")
        
        //Storyboardを指定
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //MainViewcontrollerを指定
        let initialViewController = storyboard.instantiateInitialViewController()
        //rootViewControllerに入れる
        self.window?.rootViewController = initialViewController
        //MainVCを表示
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("AppDelegate/WillResignActive/アプリ閉じる前")

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print("AppDelegate/DidEnterBackground/アプリを閉じた時")
        
        let archiveData = NSKeyedArchiver.archivedData(withRootObject: videos)
        userDefault.set(archiveData, forKey: "Videos")
        userDefault.synchronize()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print("AppDelegate/WillEnterForeground/アプリを開く前")
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("AppDelegate/DidBecomeActive/アプリを開いた時")
       
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("AppDelegate/WillTerminate/アプリ終了時(フリック)")
        
        let archiveData = NSKeyedArchiver.archivedData(withRootObject: videos)
        userDefault.set(archiveData, forKey: "Videos")
        userDefault.synchronize()
        
    }


}

