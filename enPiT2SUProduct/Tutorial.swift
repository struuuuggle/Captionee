//
//  Tutorial.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2017/12/20.
//  Copyright © 2017年 enPiT2SU. All rights reserved.
//

import MaterialComponents

class Tutorial {
    
    static var views = [UIView]()
    static var titleTexts = [String]()
    static var bodyTexts = [String]()
    
    /* チュートリアル用のViewControllerを生成する */
    static func create(_ view: UIView, _ titleText: String, _ bodyText: String, _ completion: ((Bool) -> ())?) -> MDCFeatureHighlightViewController {
        let highlightController = MDCFeatureHighlightViewController(highlightedView: view, completion: completion)
        highlightController.titleText = titleText
        highlightController.bodyText = bodyText
        highlightController.outerHighlightColor =
            MDCPalette.orange.tint500.withAlphaComponent(kMDCFeatureHighlightOuterHighlightAlpha)
        
        return highlightController
    }
    
    /* チュートリアルを表示するViewを追加する */
    static func add(_ view: UIView, _ titleText: String, _ bodyText: String) {
        views.append(view)
        titleTexts.append(titleText)
        bodyTexts.append(bodyText)
    }
    
    /* チュートリアルを表示する */
    static func show(_ viewController: UIViewController) {
        var highlightController = create(views.last!, titleTexts.last!, bodyTexts.last!, nil)
        
        for index in (0..<views.count-1).reversed() {
            let completion = { (accepted: Bool) in
                if accepted {
                    print("Accepted")
                } else {
                    print("Unaccepted")
                }
                
                viewController.present(highlightController, animated: true, completion: nil)
            }
            
            highlightController = create(views[index], titleTexts[index], bodyTexts[index], completion)
        }
        
        viewController.present(highlightController, animated: true, completion: nil)
    }
}
