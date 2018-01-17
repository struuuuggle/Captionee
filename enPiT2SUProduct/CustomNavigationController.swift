//
//  CustomNavigationController.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2018/01/16.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit
import Material
import MaterialComponents

class CustomNavigationController: NavigationController {
    open override func prepare() {
        super.prepare()
        isMotionEnabled = true
        
        guard let navigationBar = navigationBar as? NavigationBar else {
            return
        }
        
        navigationBar.depthPreset = .none
        navigationBar.backgroundColor = MDCPalette.orange.tint500
        navigationBar.dividerColor = UIColor.white
    }
}
