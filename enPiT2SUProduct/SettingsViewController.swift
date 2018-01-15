//
//  SettingViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents
import Eureka
import SafariServices

enum Language: String {
    case japanese = "日本語"
    case chinese = "中文"
    case english = "English"
    
    static func all() -> [Language] {
        return [
            Language.japanese,
            Language.chinese,
            Language.english,
        ]
    }
}

class SettingsViewController: FormViewController {

    var language: Language = .japanese
    var captionSize = "中"
    var supportModeOn = false
    
    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SettingsViewController/viewDidLoad/インスタンス化された直後（初回に一度のみ）")
        
        // ViewControllerのTitleを設定
        title = "設定"
        
        // 背景色を設定
        view.backgroundColor = MDCPalette.grey.tint100
        
        // NavigationBarの左に閉じるボタンを設置
        let closeButton = UIBarButtonItem(image: UIImage(named: "Clear"), style: .plain, target: self, action: #selector(closeButtonTapped))
        navigationItem.leftBarButtonItem = closeButton
        
        // Formを設定
        form
            +++ Section(header: "", footer: "聴覚障害者モードをオンにすると動画の再生時に音声が出なくなります。")
            // 表示言語
            <<< PushRow<String>() {
                $0.title = "表示言語"
                $0.value = language.rawValue
                $0.options = Language.all().map{$0.rawValue}
                $0.onCellSelection { cell, row in
                    print("Language selected.")
                    
                    row.deselect(animated: true)
                }
                $0.onChange { [unowned self] row in
                    if let value = row.value {
                        print("Language changed.")
                        
                        self.language = Language(rawValue: value) ?? Language.japanese
                    }
                    
                    print("Language is \(self.language)")
                    
                    row.value = self.language.rawValue
                    
                    row.reload()
                }
            }
            // 字幕サイズ
            <<< PushRow<String>() {
                $0.title = "字幕の大きさ"
                $0.value = captionSize
                $0.options = ["小", "中", "大"]
                $0.onCellSelection { cell, row in
                    print("Caption size selected.")
                    
                    row.deselect(animated: true)
                }
                $0.onChange { [unowned self] row in
                    print("Caption size changed.")
                        
                    self.captionSize = row.value ?? "中"
                        
                    print("Caption size is \(String(describing: row.value)).")
                    
                    row.value = self.captionSize
                    
                    row.reload()
                }
            }
            // 聴覚障害者モード
            <<< SwitchRow() {
                $0.title = "聴覚障害者モード"
                $0.value = false
                $0.cell.switchControl.onTintColor = MDCPalette.orange.tint500
                $0.onChange { [unowned self] row in
                    print("Support mode changed.")
                    
                    self.supportModeOn = row.value ?? false
                }
            }
            
            +++ Section("このアプリについて")
            // バージョン
            <<< LabelRow() {
                $0.title = "バージョン"
                $0.value = "1.0.0"
            }
            // プライバシーポリシー
            <<< PushRow<String>() {
                $0.title = "プライバシーポリシー"
                $0.onCellSelection { [unowned self] cell, row in
                    print("Privacy policy selected.")
                    
                    self.openSafari("https://struuuuggle.github.io/Captionee/")
                    
                    row.deselect(animated: true)
                }
            }
            // 利用規約
            <<< PushRow<String>() {
                $0.title = "利用規約"
                $0.onCellSelection { [unowned self] cell, row in
                    print("Terms of service selected.")
                    
                    self.openSafari("https://struuuuggle.github.io/Captionee/")
                    
                    row.deselect(animated: true)
                }
            }
            // ライセンス
            <<< PushRow<String>() {
                $0.title = "ライセンス"
                $0.onCellSelection { [unowned self] cell, row in
                    print("License selected.")
                    
                    self.openSafari("https://struuuuggle.github.io/Captionee/")
                    
                    row.deselect(animated: true)
                }
            }
            
            +++ Section(footer: "アプリ内の全データを削除します。")
            // データ削除
            <<< ButtonRow() {
                $0.title = "データを削除"
                $0.cell.tintColor = UIColor.red
                $0.onCellSelection { [unowned self] cell, row in
                    self.deleteAll()
                }
            }
    }
    
    /* 閉じるボタンが押されたとき */
    @objc func closeButtonTapped() {
        print("閉じる")
        
        // 設定画面を閉じる
        dismiss(animated: true, completion: nil)
    }
    
    /* 戻るボタンが押されたとき */
    @objc func backButtonTapped() {
        print("戻る")
        
        // 設定画面に戻る
        navigationController?.popViewController(animated: true)
    }
    
    /* Safariを開く */
    func openSafari(_ urlString: String) {
        let url = URL(string: urlString)
        if let url = url {
            print("Open safari success!")
            
            let safariViewController = SFSafariViewController(url: url)
            view.window?.rootViewController?.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    /* アプリ内の全データを削除する */
    func deleteAll() {
        // AlertControllerを作成
        let alert = MDCAlertController(
            title: "アプリ内の全てのデータを完全に削除しようとしています。続行しますか？",
            message: "この操作は取り消せません。"
        )
        
        // AlertActionを作成
        let ok = MDCAlertAction(title: "OK", handler: { (action) -> Void in
            print("データを削除")
            
            do {
                print("Document: \(Utility.documentDir)")
                
                let allFileName = try FileManager.default.contentsOfDirectory(atPath: Utility.documentDir)
                
                for fileName in allFileName {
                    print("\(fileName)を削除")
                    
                    try FileManager.default.removeItem(atPath: Utility.documentDir+"/"+fileName)
                }
            } catch {
                print("削除エラー")
            }
            
            self.appDelegate.videos = []
            self.appDelegate.trashVideos = []
            Utility.userDefault.removeObject(forKey: "Videos")
        })
        let cancel = MDCAlertAction(title: "CANCEL", handler: nil)
        
        // 選択肢をAlertに追加
        alert.addAction(ok)
        alert.addAction(cancel)
        
        // ダイアログ外のタップを無効化
        let presentationController = alert.mdc_dialogPresentationController
        presentationController?.dismissOnBackgroundTap = false
        
        // Alertを表示
        present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SettingsViewController/viewWillAppear/画面が表示される直前")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("SettingsViewController/viewDidAppear/画面が表示された直後")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("SettingsViewController/viewWillDisappear/別の画面に遷移する直前")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("SettingsViewController/viewDidDisappear/別の画面に遷移した直後")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("SettingsViewController/didReceiveMemoryWarning/メモリが足りないので開放される")
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
