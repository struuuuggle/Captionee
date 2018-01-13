//
//  Utility.swift
//  enPiT2SUProduct
//
//  Created by 池崎雄介 on 2018/01/12.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit

class Utility {
    
    static let userDefault = UserDefaults.standard
    
    /* DocumentDirectoryへのPath */
    static var documentDir: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    }
}
