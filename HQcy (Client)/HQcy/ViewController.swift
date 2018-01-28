//
//  ViewController.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/3/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit
import SocketIO

class ViewController: UIViewController {

    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.compress])
    var socket: SocketIOClient!
    
    let questionInput = QuestionInput()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(questionInput);
        
        socket = manager.defaultSocket
        bindSocket()
    }
    
    func bindSocket() {
        socket.on(clientEvent: .connect) {data, ack in
            self.socket.emit("is-player")
        }
        
        socket.on("question") {data, ack in
            let obj = data[0] as! NSDictionary
            let text = obj["text"] as! String
            let options = obj["options"] as! [String]
            
            self.questionInput.askQuestion(
                text: text,
                options: options,
                onAnswer: { answer in
                    ack.with(answer)
                }
            )
        }
        
        socket.on("answer") {data, _ in
            let obj = data[0] as! NSDictionary
            let votes = obj["votes"] as! [Int]
            let correctAnswer = obj["correctAnswer"] as! Int
            
            self.questionInput.showAnswer(
                votes: votes,
                correctAnswer: correctAnswer
            )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        socket.connect()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        socket.disconnect()
    }
}

