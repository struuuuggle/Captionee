//
//  UploadingViewController.swift
//  DZNEmptyDataSet
//
//  Created by 池崎雄介 on 2017/10/20.
//

import UIKit
import KRProgressHUD

class UploadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        KRProgressHUD.showOn(self).show(withMessage: "Uploading...")
        let delay = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: delay) {
            KRProgressHUD.dismiss() {
                self.success()
            }
        }
    }
    
    func success() {
        KRProgressHUD.showSuccess(withMessage: "Successfully uploaded!")
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
