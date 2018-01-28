//
//  AnswerView.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

class OptionLeftRounded: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()

        let maskPath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width, y: frame.size.height / 2.0),
            radius: frame.size.width,
            startAngle: CGFloat(.pi * 1.5),
            endAngle: CGFloat(.pi * 2.5),
            clockwise: false
        )
        
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
        layer.masksToBounds = true
    }
}

