//
//  AnswerView.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

class OptionView: UIView {
    @IBOutlet weak var leftRounded: OptionLeftRounded!
    @IBOutlet weak var rightRounded: OptionRightRounded!
    @IBOutlet weak var bar: UIView!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    func setColor(isChosen: Bool, isCorrect: Bool) {
        let barColor: UIColor
        
        if isCorrect {
            barColor = correctColor
        } else if isChosen {
            barColor = wrongColor
        } else {
            barColor = highlightedColor
        }
        
        leftRounded.backgroundColor = barColor
        bar.backgroundColor = barColor
        rightRounded.backgroundColor = isCorrect ? barColor : UIColor.clear
        
        layoutIfNeeded()
    }
    
    func showBar(votesFor: Int, totalVotes: Int) {
        let fullWidth = frame.size.width - frame.size.height
        let newWidth = CGFloat(fullWidth * (CGFloat(votesFor) / CGFloat(totalVotes)))
        
        let animationDuration = 1.0
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.init(controlPoints: 0.5, 0.20, 0.25, 1.2))
        
        UIView.animate(withDuration: animationDuration) {
            self.widthConstraint.constant = newWidth
            self.layoutIfNeeded()
        }
        
        CATransaction.commit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let newCornerRadius = bounds.size.height / 2.0
        layer.cornerRadius = newCornerRadius
        clipsToBounds = true
    }
}

