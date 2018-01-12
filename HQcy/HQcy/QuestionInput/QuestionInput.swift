//
//  QuestionInput.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/7/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

@IBDesignable
class QuestionInput: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 10 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timerLabel: TimerLabel!
    @IBOutlet weak var optionView0: OptionView!
    @IBOutlet weak var optionView1: OptionView!
    @IBOutlet weak var optionView2: OptionView!
    @IBOutlet weak var button0: OptionButton!
    @IBOutlet weak var button1: OptionButton!
    @IBOutlet weak var button2: OptionButton!
    @IBOutlet weak var votesLabel0: UILabel!
    @IBOutlet weak var votesLabel1: UILabel!
    @IBOutlet weak var votesLabel2: UILabel!
    var text: String?
    var options: [String]?
    var chosenAnswer: Int?
    var onAnswer: ((Int) -> Void)?
    
    var optionViews: [OptionView]?
    var buttons: [OptionButton]?
    var votesLabels: [UILabel]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func askQuestion(text: String, options: [String], onAnswer: @escaping (Int) -> Void) {
        self.text = text
        self.options = options
        self.onAnswer = onAnswer
        preSetup()
        postSetup(text: text, options: options, votes: nil)
    }
    
    func showAnswer(votes: [Int], correctAnswer: Int) {
        preSetup()
        
        for (index, optionView) in optionViews!.enumerated() {
            optionView.setColor(isChosen: chosenAnswer == index, isCorrect: correctAnswer == index)
        }
        for button in buttons!.enumerated() {
            button.element.isEnabled = false
        }
        for (index, votesLabel) in votesLabels!.enumerated() {
            votesLabel.text = String(votes[index])
            votesLabel.isHidden = false
        }

        postSetup(text: "hi", options: ["hey", "hi", "fuck"], votes: votes)
    }
    
    func preSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 1.0
        
        Bundle.main.loadNibNamed("QuestionInput", owner: self, options: nil)
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        view.translatesAutoresizingMaskIntoConstraints = true
        addSubview(view)
        
        optionViews = [optionView0, optionView1, optionView2]
        buttons = [button0, button1, button2]
        votesLabels = [votesLabel0, votesLabel1, votesLabel2]
    }
    
    func postSetup(text: String, options: [String], votes: [Int]?) {
        let isShowingAnswer = votes != nil
        
        translatesAutoresizingMaskIntoConstraints = false

        questionLabel.text = text
        for (index, button) in buttons!.enumerated() {
            button.setTitle(options[index], for: .normal)
        }
        
        let safeGuide = superview!.safeAreaLayoutGuide
        superview!.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: safeGuide,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        ))
        superview!.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .topMargin,
            relatedBy: .equal,
            toItem: safeGuide,
            attribute: .topMargin,
            multiplier: 1,
            constant: 10
        ))
        superview!.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: safeGuide,
            attribute: .width,
            multiplier: 1,
            constant: -20
        ))
        superview!.addConstraint(NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .equal,
            toItem: safeGuide,
            attribute: .height,
            multiplier: 0.75,
            constant: -20
        ))
        
        transform = CGAffineTransform(scaleX: 0, y: 0)
        self.layoutIfNeeded()

        if isShowingAnswer {
            var totalVotes = votes![0] + votes![1] + votes![2]
            if totalVotes == 0 {
                totalVotes = 1
            }
            
            for (index, optionView) in self.optionViews!.enumerated() {
                optionView.showBar(votesFor: votes![index], totalVotes: totalVotes)
            }
        }

        let animationDuration = 0.6
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(controlPoints: 0.65, -0.25, 0.27, 1.25))
        CATransaction.setCompletionBlock {
            self.timerLabel.startTimer()
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        
        CATransaction.commit()
        
        setTimeout(isShowingAnswer ? answerTime : questionTime, completion: {
            for button in self.buttons! {
                button.isEnabled = false
            }

            self.onAnswer = nil
            
            UIView.animate(
                withDuration: 0.3,
                delay: 2.0,
                options: [.curveEaseIn],
                animations: {
                    self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    self.layoutIfNeeded()
                },
                completion: {_ in
                    if isShowingAnswer {
                        self.chosenAnswer = nil
                        self.text = nil
                        self.options = nil
                    }
                }
            )
        })
    }
    
    @IBAction func onAnswerTap(button: OptionButton) {
        if chosenAnswer == nil {
            button.answer()
            onAnswer!(button.tag)
            chosenAnswer = button.tag
        }
    }
}
