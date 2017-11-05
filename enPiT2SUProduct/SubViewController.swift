//
//  SubViewController.swift
//  enPiT2SUProduct
//
//  Created by Mikiya Abe on 2017/11/05.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import Foundation
import UIKit

class SubViewController: UIViewController{

	@IBOutlet weak var imageView: UIImageView!
	var selectedImg: UIImage!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView.image = selectedImg
		// 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
		imageView.contentMode = UIViewContentMode.scaleAspectFit
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
