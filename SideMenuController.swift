//
//  SideMenuController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/12/22.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents
import SafariServices

class SideMenuController: UIViewController {
    
    var sideView: UIView!
    //var shadowView: UIView!
    var editButton: MDCFlatButton!
    var translateButton: MDCFlatButton!
    var tutorialButton: MDCFlatButton!
    var cancelButton: MDCFlatButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let width = view.frame.width * 2 / 3
        let height = view.frame.height / 4
        
        sideView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.height))
        view.addSubview(sideView)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = UIColor.orange
        sideView.addSubview(headerView)
        
        let buttonView = UIView(frame: CGRect(x: 0, y: height, width: width, height: UIScreen.main.bounds.height-height))
        buttonView.backgroundColor = UIColor.white
        sideView.addSubview(buttonView)
        
        let singleTapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        self.view.addGestureRecognizer(singleTapped)
        
        /*
        shadowView = UIView(frame: CGRect(x: headerView.frame.width, y: 0, width: UIScreen.main.bounds.width-width, height: UIScreen.main.bounds.height))
        shadowView.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        shadowView.addGestureRecognizer(singleTapped)
        view.addSubview(shadowView)
        */
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(panGestureRecognizer)
        
        // Itemの高さ
        let itemHeight: CGFloat = 48
        
        // 設定ボタンの設定
        editButton = MDCFlatButton(frame: CGRect(x: 0, y: 0, width: width, height: itemHeight))
        editButton.setTitle("設定", for: .normal)
        editButton.titleLabel?.font = MDCTypography.buttonFont()
        editButton.titleLabel?.alpha = MDCTypography.buttonFontOpacity()
        editButton.contentHorizontalAlignment = .left
        buttonView.addSubview(editButton)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        
        // チュートリアルボタンの設定
        translateButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight, width: view.frame.width*2/3, height: itemHeight))
        translateButton.setTitle("チュートリアル", for: .normal)
        translateButton.titleLabel?.font = MDCTypography.buttonFont()
        translateButton.titleLabel?.alpha = MDCTypography.buttonFontOpacity()
        translateButton.contentHorizontalAlignment = .left
        buttonView.addSubview(translateButton)
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        
        // フィードバックボタンの設定
        tutorialButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*2, width: view.frame.width*2/3, height: itemHeight))
        tutorialButton.setTitle("フィードバックを送信", for: .normal)
        tutorialButton.titleLabel?.font = MDCTypography.buttonFont()
        tutorialButton.titleLabel?.alpha = MDCTypography.buttonFontOpacity()
        tutorialButton.contentHorizontalAlignment = .left
        buttonView.addSubview(tutorialButton)
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        
        // ヘルプの設定
        cancelButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*3, width: view.frame.width * 2/3, height: itemHeight))
        cancelButton.setTitle("ヘルプ", for: .normal)
        cancelButton.titleLabel?.font = MDCTypography.buttonFont()
        cancelButton.titleLabel?.alpha = MDCTypography.buttonFontOpacity()
        cancelButton.contentHorizontalAlignment = .left
        buttonView.addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        
        // Viewの大きさを設定
        view.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
    }

    /* 設定ボタンが押されたとき */
    @objc func editButtonTapped() {
        print("設定")
        
        close()
        
        let settingViewController = SettingViewController()
        let navigationController = UINavigationController(rootViewController: settingViewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    /* チュートリアルボタンが押されたとき */
    @objc func translateButtonTapped() {
        print("チュートリアル")
        
        close()
    }
    
    /* フィードバックボタンが押されたとき */
    @objc func tutorialButtonTapped() {
        print("フィードバック")
        
        close()
    }
    
    /* ヘルプボタンが押されたとき */
    @objc func cancelButtonTapped() {
        print("ヘルプ")
        
        close()
        
        let url = URL(string: "https://struuuuggle.github.io/Captionee/")
        if let url = url {
            print("Open safari success!")
            
            let safariViewController = SFSafariViewController(url: url)
            view.window?.rootViewController?.present(safariViewController, animated: true, completion: nil)
        }
    }
    
    @objc func tapGesture(_ sender: UITapGestureRecognizer){
        print("ShadowView Tapped.")
        
        close()
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        // 指が離れた時（sender.state = .ended）だけ処理をする
        switch sender.state {
            
            case .ended:
                /*
            // タップ開始地点からの移動量を取得
            let position = sender.translation(in: view)
            tapEndPosX = position.x     // x方向の移動量
            // 上下左右のフリック方向を判別する
            // xがプラスの場合（右方向）とマイナスの場合（左方向）で場合分け
            if tapEndPosX > 0 {
                // 右方向へのフリック
                print("右フリック")
            } else {
                // 左方向
                print("左フリック")
            }
            */
                
                if(view.frame.origin.x + view.frame.width/2 < UIScreen.main.bounds.width/3) {
                    print("閉じる")
                    
                    close()
                } else {
                    print("戻す")
                    
                    /*ドラッグの距離が画面幅の1/2以下の場合はそのままメニューを右に戻す。
                    UIView.animate(withDuration: 0.8, animations: {
                        self.view.frame = CGRect(x:0, y:0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    }, completion:nil)
 */
                    beginAppearanceTransition(true, animated: true)
                    view.frame = view.frame.offsetBy(dx: -self.view.frame.size.width, dy: 0)
                    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        let bounds = self.view.bounds
                        self.view.frame = CGRect(x:0, y:0, width:bounds.size.width, height:bounds.size.height)
                    }, completion: {_ in
                        self.endAppearanceTransition()
                    })
                    
            }
                
            
            
        case .changed:
            print("ドラッグ中")
            
            //移動量を取得する。
            let move: CGPoint = sender.translation(in: view)
            
            //画面の端からの移動量
            view.frame.origin.x += move.x
            
            //移動量をリセットする。
            sender.setTranslation(CGPoint.zero, in: view)
            
            if sideView.frame.origin.x + move.x <= 0 {
                //画面の端からの移動量
                sideView.frame.origin.x += move.x
                let closeValue = sideView.frame.origin.x / (UIScreen.main.bounds.width * 2 / 3)
                view.backgroundColor = UIColor(white: 0.2, alpha: 0.3*closeValue)
                
                //移動量をリセットする。
                sender.setTranslation(CGPoint.zero, in: view)
            }
            
           
        default:
            break
        }
    }
    
    func close() {
        //shadowView.isHidden = true
        view.frame.size = CGSize(width: UIScreen.main.bounds.width*2/3, height: UIScreen.main.bounds.height)
        beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.view.frame = self.view.frame.offsetBy(dx: -UIScreen.main.bounds.size.width, dy: 0)
        }, completion: {_ in
            self.endAppearanceTransition()
            self.view.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            //self.shadowView.isHidden = false
        })
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

