//
//  SettingViewController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/11/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents

class SettingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // AppDelegateの変数にアクセスする用
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    // テーマカラーを設定するためのPickerView
    var colorPicker: UIPickerView!
    // テーマカラーのリスト
    var colorList: [String]!
    
    // テーマカラーを表示するためのTextField
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // UIPickerViewを生成.
        colorPicker = UIPickerView()
        // Delegateを設定する.
        colorPicker.delegate = self
        // DataSourceを設定する.
        colorPicker.dataSource = self
        
        // テーマカラーのリストを設定
        colorList = [String](appDelegate.color.keys)
        
        // testTextFieldのdelegateを設定
        textField.delegate = self
        
        // TextFieldに現在のテーマカラーを設定
        textField.text = appDelegate.themeColor
        
        // 閉じるボタンのツールバー生成
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default
        kbToolBar.sizeToFit()
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        // 閉じるボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(commitButtonTapped))
        
        // ツールバーのアイテムを設定
        kbToolBar.items = [spacer, commitButton]
        
        // TextFieldの入力方法を設定
        textField.inputView = colorPicker
        textField.inputAccessoryView = kbToolBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //閉じるボタンが押されたらキーボードを閉じる
    @objc func commitButtonTapped (){
        self.view.endEditing(true)
    }
    
    //コンポーネントの個数を返すメソッド
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //コンポーネントに含まれるデータの個数を返すメソッド
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colorList.count
    }
    
    //データを返すメソッド
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return colorList[row]
    }
    
    //データ選択時の呼び出しメソッド
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        //コンポーネントごとに現在選択されているデータを取得する。
        let color = self.pickerView(pickerView, titleForRow: pickerView.selectedRow(inComponent: 0), forComponent: 0)!
        
        // TextFieldに変更後のテーマカラーを設定
        textField.text = color
        
        // AppDelegateのテーマカラーを設定
        appDelegate.themeColor = color
        
        // NavigationBarの背景色のテーマカラーを設定
        navigationController?.navigationBar.backgroundColor = appDelegate.color[color]
        
        print("Theme color is \(appDelegate.themeColor)")
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
