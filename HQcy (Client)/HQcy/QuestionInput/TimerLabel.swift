//
//  TimerLabel.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/8/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

let timerLabelBorderWidth: CGFloat = 5.0
var timeLeft: Int = 10

class TimerLabel: UILabel {
    var timer: Timer?
    let circleLayer = CAShapeLayer()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)!
        self.setup()
    }
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup() {
        let borderLayer = CAShapeLayer()
        let borderPath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: (frame.size.width - 10) / 2,
            startAngle: 0,
            endAngle: CGFloat(.pi * 2.0),
            clockwise: true
        )
        borderLayer.path = borderPath.cgPath
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0).cgColor
        borderLayer.lineWidth = timerLabelBorderWidth;
        borderLayer.strokeEnd = 1.0
        layer.addSublayer(borderLayer)

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: (frame.size.width - 10) / 2,
            startAngle: CGFloat(.pi * 1.5),
            endAngle: CGFloat(.pi * 3.5),
            clockwise: true
        )
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor(red:0.87, green:0.21, blue:0.42, alpha:1.0).cgColor
        circleLayer.lineWidth = timerLabelBorderWidth;
        circleLayer.strokeEnd = 0.0
        layer.addSublayer(circleLayer)
    }
    
    func startTimer() {
        timeLeft = 10
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(advance)), userInfo: nil, repeats: true)
 
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = questionTime
        animation.fromValue = 0
        animation.toValue = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        circleLayer.strokeEnd = 1.0
        circleLayer.add(animation, forKey: "animateCircle")
    }

    @objc func advance() {
        playSound(resourceName: "tick")
        timeLeft -= 1
        text = String(timeLeft)
        if timeLeft == 0 {
            timeUp()
        }
    }
    
    func timeUp() {
        playSound(resourceName: "time-up")
        timer!.invalidate()
        timer = nil
    }

}
