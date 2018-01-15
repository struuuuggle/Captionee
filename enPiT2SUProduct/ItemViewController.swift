//
//  ItemViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/12/19.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents

class ItemViewController: UIViewController {
    
    weak var delegate: ItemDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Viewの背景を白に設定
        view.backgroundColor = UIColor.white
        
        // Itemの高さ
        let itemHeight: CGFloat = 48
        
        // 編集ボタンの設定
        let editButton = MDCFlatButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: itemHeight))
        editButton.setTitle("字幕を編集", for: .normal)
        editButton.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        editButton.alpha = MDCTypography.subheadFontOpacity()
        editButton.contentHorizontalAlignment = .left
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        view.addSubview(editButton)
        
        // 翻訳ボタンの設定
        let translateButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight, width: view.frame.width, height: itemHeight))
        translateButton.setTitle("字幕を翻訳", for: .normal)
        translateButton.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        translateButton.alpha = MDCTypography.subheadFontOpacity()
        translateButton.contentHorizontalAlignment = .left
        translateButton.addTarget(self, action: #selector(translateButtonTapped), for: .touchUpInside)
        view.addSubview(translateButton)
        
        // チュートリアルボタンの設定
        let tutorialButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*2, width: view.frame.width, height: itemHeight))
        tutorialButton.setTitle("チュートリアル", for: .normal)
        tutorialButton.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        tutorialButton.alpha = MDCTypography.subheadFontOpacity()
        tutorialButton.contentHorizontalAlignment = .left
        tutorialButton.addTarget(self, action: #selector(tutorialButtonTapped), for: .touchUpInside)
        view.addSubview(tutorialButton)
        
        // キャンセルボタンの設定
        let cancelButton = MDCFlatButton(frame: CGRect(x: 0, y: itemHeight*3, width: view.frame.width, height: itemHeight))
        cancelButton.setTitle("キャンセル", for: .normal)
        cancelButton.setTitleFont(MDCTypography.subheadFont(), for: .normal)
        cancelButton.alpha = MDCTypography.subheadFontOpacity()
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        view.addSubview(cancelButton)
        
        // Viewの大きさを設定
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: itemHeight*4)
    }
    
    /* 編集ボタンが押されたとき */
    @objc func editButtonTapped() {
        dismiss(animated: true, completion: nil)
        
        // delegate先に処理を投げる
        delegate?.editButtonTapped()
    }
    
    /* 翻訳ボタンが押されたとき */
    @objc func translateButtonTapped() {
        dismiss(animated: true, completion: nil)
        
        // delegate先に処理を投げる
        delegate?.translateButtonTapped()
    }
    
    /* チュートリアルボタンが押されたとき */
    @objc func tutorialButtonTapped() {
        dismiss(animated: true, completion: nil)
        
        // delegate先に処理を投げる
        delegate?.tutorialButtonTapped()
    }
    
    /* キャンセルボタンが押されたとき */
    @objc func cancelButtonTapped() {
        print("キャンセル")
        
        // BottomSheetを閉じる
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

/* ItemViewControllerのdelegate */
protocol ItemDelegate: class {
    // 編集ボタン用
    func editButtonTapped()
    // 翻訳ボタン用
    func translateButtonTapped()
    // チュートリアルボタン用
    func tutorialButtonTapped()
}
