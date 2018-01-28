//
//  AnswerButton.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

class Popup: UILabel {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newCornerRadius = bounds.size.height / 2.0
        layer.cornerRadius = newCornerRadius
        clipsToBounds = true
    }
}

