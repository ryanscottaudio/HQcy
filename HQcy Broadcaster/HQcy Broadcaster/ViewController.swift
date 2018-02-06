//
//  ViewController.swift
//  HQcy Broadcaster
//
//  Created by Ryan Campbell on 1/5/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import Cocoa
import SocketIO

class ViewController: NSViewController, NSWindowDelegate {
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.compress])
    var socket: SocketIOClient!
    
    @IBOutlet var askButton: NSButton!
    @IBOutlet var textLabel: NSTextField!
    @IBOutlet var option0Label: NSTextField!
    @IBOutlet var option1Label: NSTextField!
    @IBOutlet var option2Label: NSTextField!
    var optionLabels: [NSTextField]!
    @IBOutlet var votes0Label: NSTextField!
    @IBOutlet var votes1Label: NSTextField!
    @IBOutlet var votes2Label: NSTextField!
    var votesLabels: [NSTextField]!
    var currentQuestion: Int = -1
    
    override func viewDidAppear() {
        view.window?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionLabels = [option0Label, option1Label, option2Label]
        votesLabels = [votes0Label, votes1Label, votes2Label]
        
        socket = manager.defaultSocket
        
        startSocket()
    }
    
    func startSocket() {
        socket.on(clientEvent: .connect) {data, ack in
            self.socket.emit("is-broadcaster")
        }
        
        socket.on("question") {data, _ in
            self.askButton.isEnabled = false
            
            for (label) in self.votesLabels {
                label.isHidden = true
            }
            
            let obj = data[0] as! NSDictionary
            let text = obj["text"] as! String
            let options = obj["options"] as! [String]
            let correctAnswer = obj["correctAnswer"] as! Int
            
            self.textLabel.isHidden = false
            self.textLabel.stringValue = text
            
            for (index, label) in self.optionLabels.enumerated() {
                label.isHidden = false
                label.stringValue = options[index]
                label.backgroundColor = index == correctAnswer ? NSColor(red:0.00, green:0.39, blue:0.00, alpha:1.0) : NSColor.black
            }
        }
        
        socket.on("answer") {data, _ in
            let votes = data[0] as! [Int]
            
            for (index, label) in self.votesLabels.enumerated() {
                label.isHidden = false
                label.stringValue = String(votes[index])
            }

            self.askButton.isEnabled = true
        }
        
        socket.connect()
    }
    
    @IBAction func askQuestion(_ sender: NSButton) {
        socket.emit("ask-question")
    }
 
}
