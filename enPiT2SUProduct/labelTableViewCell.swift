//
//  labelTableViewCell.swift
//  enPiT2SUProduct
//
//  Created by 佐々木友哉 on 2017/12/10.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit

//デリゲート先に適用してもらうプロトコル
protocol TestDelegate {
    func textFieldDidEndEditing(cell:TestTableViewCell, value:String)
}


class TestTableViewCell: UITableViewCell, UITextFieldDelegate {
    

    
    var delegate:TestDelegate! = nil
    
    
    //最初からある初期化メソッド
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //テキストフィールドのデリゲート先を自分に設定する。
        testTextField.delegate = self
    }
    
    
    //最初からあるメソッド
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    //デリゲートメソッド
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        //キーボードを閉じる。
        textField.resignFirstResponder()
        return true
    }
    
    
    //デリゲートメソッド
    func textFieldDidEndEditing(textField: UITextField) {
        //テキストフィールドから受けた通知をデリゲート先に流す。
        self.delegate.textFieldDidEndEditing(self, value:textField.text!)
    }
}
