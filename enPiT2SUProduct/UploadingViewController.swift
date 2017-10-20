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
        let statusBar = UIView(frame:CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        statusBar.backgroundColor = UIColor.orange
        view.addSubview(statusBar)
        
        KRProgressHUD.showOn(self).show(withMessage: "processing...")
        let delay = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: delay) {
            KRProgressHUD.dismiss() {
                self.success()
            }
        }
    }
	
    func success() {
        KRProgressHUD.showSuccess(withMessage: "Successfully processed!")
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
