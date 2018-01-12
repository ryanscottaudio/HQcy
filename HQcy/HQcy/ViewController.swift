//
//  ViewController.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/3/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit
import SocketIO
import IJKMediaFramework

class ViewController: UIViewController {
    var player: IJKFFMoviePlayerController!

    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.compress])
    var socket: SocketIOClient!
    
    let questionInput = QuestionInput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let playerOptions = IJKFFOptions.byDefault()!;
//        playerOptions.setPlayerOptionIntValue(1, forKey: "framedrop");
        player = IJKFFMoviePlayerController(contentURL: URL(string: videoUrl)!, with: playerOptions)
        
        player?.view.frame = self.view.bounds
        
        view.autoresizesSubviews = true
        player.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        player.scalingMode = .aspectFill
        player.shouldAutoplay = true
        player.view.frame = view.bounds
        view.addSubview(player.view)

        player.prepareToPlay()

        view.addSubview(questionInput);

        socket = manager.defaultSocket
        bindSocket()
    }
    
    func bindSocket() {
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
        player.play()
        socket.connect()
        print(player.view.frame)
        view.layoutIfNeeded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.shutdown()
        socket.disconnect()
    }
}

