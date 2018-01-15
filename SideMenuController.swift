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
    
    weak var delegate: SideMenuDelegate? = nil
    
    var sideView: UIView!
    var shadowView: UIView!
    
    // 画面の横のサイズ
    let screenWidth = UIScreen.main.bounds.width
    // 画面の縦のサイズ
    let screenHeight = UIScreen.main.bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SideViewの横のサイズ
        let width = screenWidth * 2 / 3
        // HeaderViewの縦のサイズ
        let height = screenHeight / 4
        
        view.frame = CGRect(x: -screenWidth, y:0, width: screenWidth, height: screenHeight)
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        
        shadowView = UIView(frame: CGRect(x: width, y: 0, width: screenWidth/3, height: screenHeight))
        shadowView.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
        view.addSubview(shadowView)
        
        sideView = UIView(frame: CGRect(x: -width, y: 0, width: width, height: screenHeight))
        view.addSubview(sideView)
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        headerView.backgroundColor = UIColor.orange
        sideView.addSubview(headerView)
        
        let buttonView = UIView(frame: CGRect(x: 0, y: height, width: width, height: screenHeight-height))
        buttonView.backgroundColor = UIColor.white
        sideView.addSubview(buttonView)
        
        let singleTapped = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
        shadowView.addGestureRecognizer(singleTapped)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        view.addGestureRecognizer(panGestureRecognizer)
        
        // Itemの高さ
        let itemHeight: CGFloat = 48
        
        // Iconの色
        let iconColor = MDCPalette.grey.tint100
        
        // メインボタンの設定
        let mainButton = MDCFlatButton(frame: CGRect(x: 0, y: 0, width: width, height: itemHeight))
        mainButton.setTitle("メイン", for: .normal)
        mainButton.setImage(UIImage(named: "Main"), for: .normal)
        mainButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        mainButton.tintColor = UIColor.red
        mainButton.contentHorizontalAlignment = .left
        mainButton.addTarget(self, action: #selector(mainButtonTapped), for: .touchUpInside)
        buttonView.addSubview(mainButton)
        mainButton.tintColor = UIColor.red
        
        // ゴミ箱ボタンの設定
        let trashButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight, width: width, height: itemHeight))
        trashButton.setTitle("ゴミ箱", for: .normal)
        trashButton.setImage(UIImage(named: "Trash"), for: .normal)
        trashButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        trashButton.tintColor = iconColor
        trashButton.contentHorizontalAlignment = .left
        trashButton.addTarget(self, action: #selector(trashButtonTapped), for: .touchUpInside)
        buttonView.addSubview(trashButton)
        
        // 設定ボタンの設定
        let settingsButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*2, width: width, height: itemHeight))
        settingsButton.setTitle("設定", for: .normal)
        settingsButton.setImage(UIImage(named: "Setting"), for: .normal)
        settingsButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        settingsButton.tintColor = iconColor
        settingsButton.contentHorizontalAlignment = .left
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        buttonView.addSubview(settingsButton)
        
        // チュートリアルボタンの設定
        let tutorialButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*3, width: width, height: itemHeight))
        tutorialButton.setTitle("チュートリアル", for: .normal)
        tutorialButton.setImage(UIImage(named: "Tutorial"), for: .normal)
        tutorialButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        tutorialButton.tintColor = iconColor
        tutorialButton.contentHorizontalAlignment = .left
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        buttonView.addSubview(tutorialButton)
        
        // フィードバックボタンの設定
        let feedbackButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*4, width: width, height: itemHeight))
        feedbackButton.setTitle("フィードバックを送信", for: .normal)
        feedbackButton.setImage(UIImage(named: "Feedback"), for: .normal)
        feedbackButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        feedbackButton.tintColor = iconColor
        feedbackButton.contentHorizontalAlignment = .left
        feedbackButton.addTarget(self, action: #selector(feedbackButtonTapped), for: .touchUpInside)
        buttonView.addSubview(feedbackButton)
        
        // ヘルプの設定
        let helpButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*5, width: width, height: itemHeight))
        helpButton.setTitle("ヘルプ", for: .normal)
        helpButton.setImage(UIImage(named: "Help"), for: .normal)
        helpButton.setTitleFont(MDCTypography.buttonFont(), for: .normal)
        helpButton.tintColor = iconColor
        helpButton.contentHorizontalAlignment = .left
        helpButton.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
        buttonView.addSubview(helpButton)
    }
    
    /* メインボタンが押されたとき */
    @objc func mainButtonTapped() {
        close()
        
        delegate?.mainButtonTapped()
    }
    
    /* ゴミ箱が押されたとき */
    @objc func trashButtonTapped() {
        close()
        
        delegate?.trashButtonTapped()
    }

    /* 設定ボタンが押されたとき */
    @objc func settingsButtonTapped() {
        close()
        
        delegate?.settingsButtonTapped()
    }
    
    /* チュートリアルボタンが押されたとき */
    @objc func tutorialButtonTapped() {
        close()
        
        delegate?.tutorialButtonTapped()
    }
    
    /* フィードバックボタンが押されたとき */
    @objc func feedbackButtonTapped() {
        close()
        
        delegate?.feedbackButtonTapped()
    }
    
    /* ヘルプボタンが押されたとき */
    @objc func helpButtonTapped() {
        close()
        
        delegate?.helpButtonTapped()
    }
    
    /* SideMenuの外がタップされたとき */
    @objc func tapGesture(_ sender: UITapGestureRecognizer){
        print("ShadowView Tapped.")
        
        close()
    }
    
    /* SideMenuがドラッグされたとき */
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        dragging(sender.state, sender.translation(in: view))
        
        //移動量をリセットする。
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    /* SideMenuを開く */
    func open() {
        print("開く")
        
        view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        beginAppearanceTransition(true, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.sideView.frame = CGRect(x: 0, y: 0, width: self.sideView.frame.width, height: self.screenHeight)
        }, completion: { _ in
            self.endAppearanceTransition()
        })
    }
    
    /* SideMenuを閉じる */
    func close() {
        print("閉じる")
        
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.0)
        beginAppearanceTransition(false, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.sideView.frame = CGRect(x: -self.sideView.frame.width, y: 0, width: self.sideView.frame.width, height: self.screenHeight)
        }, completion: {_ in
            self.endAppearanceTransition()
            self.view.frame = CGRect(x: -self.screenWidth, y: 0, width: self.screenWidth, height: self.screenHeight)
        })
    }
    
    /* SideMenuをドラッグ中 */
    func dragging(_ state: UIGestureRecognizerState, _ move: CGPoint) {
        switch state {
        case .ended:
            if sideView.frame.origin.x + sideView.frame.width > screenWidth / 3 {
                open()
            } else {
                close()
            }
        case .changed:
            print("ドラッグ中")
            
            view.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
            if sideView.frame.origin.x + move.x <= 0 {
                //画面の端からの移動量
                sideView.frame.origin.x += move.x
                
                let closeValue = (sideView.frame.origin.x + sideView.frame.width) / (sideView.frame.width)
                view.backgroundColor = UIColor(white: 0.2, alpha: min(0.3, 0.3*closeValue))
            }
        default:
            break
        }
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

/* SideMenuControllerのdelegate */
protocol SideMenuDelegate: class {
    // メインボタン用
    func mainButtonTapped()
    // ゴミ箱ボタン用
    func trashButtonTapped()
    // 設定ボタン用
    func settingsButtonTapped()
    // チュートリアルボタン用
    func tutorialButtonTapped()
    // フィードバックボタン用
    func feedbackButtonTapped()
    // ヘルプボタン用
    func helpButtonTapped()
}

