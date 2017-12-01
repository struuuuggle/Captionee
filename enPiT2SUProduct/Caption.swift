//
//  Caption.swift
//  enPiT2SUProduct
//
//  Created by 池崎雄介 on 2017/11/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit

class Caption {
    
    var words: [[String]]!
    var startTimes: [[Double]]!
    var endTimes: [[Double]]!
    
    init(_ words: [[String]], _ startTimes: [[Double]], _ endTimes: [[Double]]) {
        self.words = words
        self.startTimes = startTimes
        self.endTimes = endTimes
    }
    
}
