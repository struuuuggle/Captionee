//
//  VideoInfo.swift
//
//  Created by team-E on 2017/10/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit

/* TableViewで管理する動画の情報 */
struct VideoInfo {
    
    var name: String
    var image: UIImage
    var label: String
    var caption: String
    
    init(_ name: String, _ image: UIImage, _ label: String) {
        self.name = name
        self.image = image
        self.label = label
        self.caption = ""
    }
    
}
