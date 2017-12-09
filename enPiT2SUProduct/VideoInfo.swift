//
//  VideoInfo.swift
//
//  Created by team-E on 2017/10/30.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import UIKit

/* 動画の情報を管理するクラス */
class VideoInfo: NSObject, NSCoding {
    
    var name: String
    var image: UIImage
    var label: String
    var caption: Caption?
    
    init(_ name: String, _ image: UIImage, _ label: String) {
        self.name = name
        self.image = image
        self.label = label
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(image, forKey: "Image")
        aCoder.encode(label, forKey: "Label")
        aCoder.encode(caption, forKey: "Caption")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        image = aDecoder.decodeObject(forKey: "Image") as! UIImage
        label = aDecoder.decodeObject(forKey: "Label") as! String
        caption = aDecoder.decodeObject(forKey: "Caption") as? Caption
    }
    
}
