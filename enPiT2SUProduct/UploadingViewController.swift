//
//  UploadingViewController.swift
//
//  Created by team-E on 2017/10/20.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
// インジゲータを表示させるライブラリ
import KRProgressHUD

class UploadingViewController: UIViewController {

    /* Viewがロードされたとき */
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // StatusBarの設定
        let statusBar = StatusBar(.orange)
        view.addSubview(statusBar)
        
        // KRProgressHUDの設定
        KRProgressHUD.showOn(self).show(withMessage: "processing...")
        let delay = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: delay) {
            KRProgressHUD.dismiss() {
                self.success()
            }
        }
    }

    /* メモリエラーが発生したとき */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 動画のアップロードに成功したとき */
    func success() {
        KRProgressHUD.showSuccess(withMessage: "Successfully processed!")
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
