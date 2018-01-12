//
//  AnswerView.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

class OptionBackground: UIView {
    @IBInspectable var borderWidth: CGFloat = 2 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = highlightedColor {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newCornerRadius = bounds.size.height / 2.0
        layer.cornerRadius = newCornerRadius
        clipsToBounds = true
    }
}
