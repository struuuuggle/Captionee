//
//  StatusBar.swift
//  
//  Created by 池崎雄介 on 2017/10/28.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit

class StatusBar: UIView {
    
    init(_ color: UIColor) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: 20.0))
        super.backgroundColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
