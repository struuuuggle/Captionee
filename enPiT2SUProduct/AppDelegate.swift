//
//  AppDelegate.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/09/15.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var themeColor = "Orange"
    let colors = ["Red": MDCPalette.red.tint700, "Orange": MDCPalette.orange.tint500,
                 "Yellow": MDCPalette.yellow.tint500, "Green": MDCPalette.green.tint500,
                 "Blue": MDCPalette.blue.tint500]
    var language = "日本語"
    let languages = ["日本語", "中文", "한국어", "English"]
    var videos = [VideoInfo]()
    let userDefault = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // NavigationBarの設定
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = colors[themeColor]
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
        
        let onboarding = OnboadingViewController()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = onboarding
        window?.makeKeyAndVisible()
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

