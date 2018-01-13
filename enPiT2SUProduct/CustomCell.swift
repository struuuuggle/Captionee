//
//  CustomCell.swift
//  enPiT2SUProduct
//
//  Created by team-E on 2018/01/13.
//  Copyright © 2018年 enPiT2SU. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {
    var myImageView: UIImageView!
    var label: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        myImageView = UIImageView()
        myImageView.tag = 1
        contentView.addSubview(myImageView)
        
        label = UILabel(frame: CGRect.zero)
        label.textAlignment = .left
        label.tag = 2
        contentView.addSubview(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let superview = myImageView.superview {
            myImageView.translatesAutoresizingMaskIntoConstraints = false
            myImageView.topAnchor.constraint(equalTo: superview.topAnchor, constant: 5).isActive = true
            myImageView.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 5).isActive = true
            myImageView.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -5).isActive = true
            myImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
            
            label.translatesAutoresizingMaskIntoConstraints = false
            label.topAnchor.constraint(equalTo: superview.layoutMarginsGuide.topAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: myImageView.trailingAnchor, constant: 20).isActive = true
            label.bottomAnchor.constraint(equalTo: superview.layoutMarginsGuide.bottomAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -5).isActive = true
        }
    }
    
}
