//
//  SideMenuController.swift
//  enPiT2SUProduct
//
//  Created by 佐々木友哉 on 2017/12/22.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit
import MaterialComponents

class SideMenuController: UIViewController, UINavigationControllerDelegate {
    let appBar = MDCAppBar()
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.addChildViewController(appBar.headerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
         appBar.addSubviewsToParent()
        
        // Viewの大きさを設定
        view.frame = CGRect(x: 0, y:0, width: UIScreen.main.bounds.width * 2/3 , height: UIScreen.main.bounds.height)
        
        view.backgroundColor = UIColor.lightGray
        
        appBar.navigationBar.backgroundColor = UIColor.orange
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
