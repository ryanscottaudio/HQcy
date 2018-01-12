//
//  AnswerButton.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

@IBDesignable
class OptionButton: UIButton {    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let height = bounds.size.height

        let newCornerRadius = height / 2.0
        layer.cornerRadius = newCornerRadius
        clipsToBounds = true
        titleEdgeInsets = UIEdgeInsetsMake(0.0, height / 2.0, 0.0, 0.0)
        titleLabel!.font = titleLabel!.font.withSize(height / 3.5)
    }
    
    func answer() {
        layer.borderColor = selectedColor.cgColor
        layer.backgroundColor = selectedColor.cgColor
        setTitleColor(UIColor.white, for: .normal)
    }
}
