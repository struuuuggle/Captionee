//
//  AppDelegate.swift
//
//  Created by team-E on 2017/09/15.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents
import Onboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var themeColor = "Orange"
	let userDefault = UserDefaults.standard
    let color = [
		"Red": MDCPalette.red.tint700,
		"Orange": MDCPalette.orange.tint500,
        "Yellow": MDCPalette.yellow.tint500,
		"Green": MDCPalette.green.tint500,
        "Blue": MDCPalette.blue.tint500
	]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // NavigationBarの設定
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = MDCPalette.orange.tint500
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-UltraLight", size: 25)!
        ]
        UINavigationBar.appearance().isTranslucent = false
        
        UIToolbar.appearance().tintColor = MDCPalette.grey.tint500
        
        // 起動時間延長
        sleep(2)
        
        let dict = ["firstLaunch": true]
        self.userDefault.register(defaults: dict)
		
		// 初回起動時のみに実行する処理
        if userDefault.bool(forKey: "firstLaunch") {
            userDefault.set(false, forKey: "firstLaunch")
            print("Captioneeが初めて起動されました")
			// ウォークスルーを表示
			self.playWalkthrough()
		}
		
        /* 起動時に毎回呼び出される処理 */
		
        return true
    }
	
	/* アプリが初めて起動されたかを判定する */
	func isFristLaunch() -> Bool {
		return true
	}
	
	/* ウォークスルーの表示 */
	func playWalkthrough() {
		// 背景画像
		let bgImage = UIImage(named: "AppIcon")

		// 1ページ目の設定
		let firstPage = OnboardingContentViewController.content(withTitle: "Title 1",
																body: "Body 1",
																image: UIImage(named: "Setting"),	// 画像を表示しない場合はnilにする
																buttonText: "Next",
																action: nil)
		firstPage.movesToNextViewController = true
		
		// 2ページ目の設定
		let secondPage = OnboardingContentViewController.content(withTitle: "Title 2",
																 body: "Body 2",
																 image: UIImage(named: "Setting"),
																 buttonText: "Next",
																 action:nil)
		secondPage.movesToNextViewController = true
		
		// 3ページ目の設定
		let content3 = OnboardingContentViewController(
			title: "Title3",
			body: "Body3",
			image: nil,
			buttonText: "さあ、始めよう！",
			action: {
				self.getStarted()
            }
		)
		
		// onboardingViewcontrollerのインスタンスを生成する
		let walkthroughVC = OnboardingViewController(backgroundImage: bgImage,
                                                     contents: [content1, content2, content3])
		// スキップボタンの表示
		walkthroughVC?.allowSkipping = true
		// スキップボタンを押した時の動作
		walkthroughVC?.skipHandler = { self.skip() }
		
//		onboardingVC?.shouldMaskBackground = false
//		onboardingVC?.shouldBlurBackground = true
//		onboardingVC?.shouldFadeTransitions = true
//		onboardingVC?.fadePageControlOnLastPage = true
//		onboardingVC?.fadeSkipButtonOnLastPage = true
		onboardingVC?.allowSkipping = false
//		onboardingVC?.skipHandler = { self.skip() }

		
		// onboardingVCを表示
		window?.rootViewController = onboardingVC
		print("ウォークスルー表示")
	}
	
	/* ウォークスルーを終了させる */
	func getStarted() {
		//Storyboardを指定
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		//MainViewcontrollerを指定
		let initialViewController = storyboard.instantiateInitialViewController()
		//rootViewControllerに入れる
		self.window?.rootViewController = initialViewController
		//MainVCを表示
		self.window?.makeKeyAndVisible()
	}
	
	/* ウォークスルー中にskipボタンを押した時の処理 */
	func skip() {
		self.getStarted()
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

    }


}

