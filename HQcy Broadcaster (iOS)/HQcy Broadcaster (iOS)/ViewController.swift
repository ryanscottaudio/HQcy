//
//  ViewController.swift
//  HQcy Broadcaster (iOS)
//
//  Created by Ryan Campbell on 1/14/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit
import AVFoundation
import SocketIO

class ViewController: UIViewController, RTCEAGLVideoViewDelegate, ARDAppClientDelegate {
    @IBOutlet weak var remoteView:RTCEAGLVideoView?
    @IBOutlet weak var localView:RTCEAGLVideoView?
    //Auto Layout Constraints used for animations
    @IBOutlet weak var remoteViewTopConstraint:NSLayoutConstraint?
    @IBOutlet weak var remoteViewRightConstraint:NSLayoutConstraint?
    @IBOutlet weak var remoteViewLeftConstraint:NSLayoutConstraint?
    @IBOutlet weak var remoteViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var localViewWidthConstraint:NSLayoutConstraint?
    @IBOutlet weak var localViewHeightConstraint:NSLayoutConstraint?
    @IBOutlet weak var  localViewRightConstraint:NSLayoutConstraint?
    @IBOutlet weak var  localViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var  footerViewBottomConstraint:NSLayoutConstraint?
    @IBOutlet weak var  buttonContainerViewLeftConstraint:NSLayoutConstraint?
    
    let manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.compress])
    var socket: SocketIOClient!
    
    @IBOutlet var askButton: UIButton!
    @IBOutlet var textLabel: UILabel!
    @IBOutlet var option0Label: UILabel!
    @IBOutlet var option1Label: UILabel!
    @IBOutlet var option2Label: UILabel!
    var optionLabels: [UILabel]!
    @IBOutlet var votes0Label: UILabel!
    @IBOutlet var votes1Label: UILabel!
    @IBOutlet var votes2Label: UILabel!
    var votesLabels: [UILabel]!
    var currentQuestion: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        optionLabels = [option0Label, option1Label, option2Label]
        votesLabels = [votes0Label, votes1Label, votes2Label]
        
        socket = manager.defaultSocket
        
//        startCamera()
        startSocket()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            self.textLabel.text = text
            
            for (index, label) in self.optionLabels.enumerated() {
                label.isHidden = false
                label.text = options[index]
                label.backgroundColor = index == correctAnswer ? UIColor(red:0.00, green:0.39, blue:0.00, alpha:1.0) : UIColor.black
            }
        }
        
        socket.on("answer") {data, _ in
            let votes = data[0] as! [Int]
            
            for (index, label) in self.votesLabels.enumerated() {
                label.isHidden = false
                label.text = String(votes[index])
            }
            
            self.askButton.isEnabled = true
        }
        
        socket.connect()
    }
    
    @IBAction func askQuestion(_ sender: UIButton) {
        socket.emit("ask-question")
    }
    
    func appClient(_ client: ARDAppClient!, didChange state: ARDAppClientState) {
        switch (state) {
        case .connected:
            print("Client connected.");
        case .connecting:
            print("Client connecting.");
        case .disconnected:
            print("Client disconnected.");
            self.remoteDisconnected();
        }
    }
    
    public func appClient(_ client: ARDAppClient!, didError error: Error!) {
        let alert = UIAlertView(title: "Error", message: error.localizedDescription, delegate: nil, cancelButtonTitle: "close")
        alert.show()
        self.disconnect()
    }
    
    func appClient(_ client: ARDAppClient!, didReceiveLocalVideoTrack localVideoTrack: RTCVideoTrack!) {
        self.localVideoTrack?.remove(self.localView!)
        self.localView?.renderFrame(nil)
        self.localVideoTrack=localVideoTrack
        self.localVideoTrack?.add(self.localView!)
        
    }
    
    public func appClient(_ client: ARDAppClient!, didCreateLocalCapturer localCapturer: RTCCameraVideoCapturer!) {
        let settingsModel = ARDSettingsModel()
        captureController = ARDCaptureController(capturer: localCapturer, settings: settingsModel)
        captureController.startCapture()
    }
    
    
    func appClient(_ client: ARDAppClient!, didReceiveRemoteVideoTrack remoteVideoTrack: RTCVideoTrack!) {
        self.remoteVideoTrack=remoteVideoTrack
        self.remoteVideoTrack?.add(self.remoteView!)
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.localViewBottomConstraint?.constant=28.0
            self.localViewRightConstraint?.constant=28.0
            self.localViewHeightConstraint?.constant=self.view.frame.size.height/4
            self.localViewWidthConstraint?.constant=self.view.frame.size.width/4
            self.footerViewBottomConstraint?.constant = -80.0
        })
    }
    
    func appclient(_ client: ARDAppClient!, didRotateWithLocal localVideoTrack: RTCVideoTrack!, remoteVideoTrack: RTCVideoTrack!) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ViewController.updateUIForRotation), object: nil)
        // Hack for rotation to get the right video size
        self.perform(#selector(ViewController.updateUIForRotation), with: nil, afterDelay: 0.2)
    }
    
    public func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
    }
    
    public func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        
    }
    
    func videoView(_ videoView: RTCEAGLVideoView, didChangeVideoSize size: CGSize) {
        let orientation: UIInterfaceOrientation = UIApplication.shared.statusBarOrientation
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            let containerWidth: CGFloat = self.view.frame.size.width
            let containerHeight: CGFloat = self.view.frame.size.height
            let defaultAspectRatio: CGSize = CGSize(width: 4, height: 3)
            if videoView == self.localView {
                self.localVideoSize = size
                let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
                var videoRect: CGRect = self.view.bounds
                if (self.remoteVideoTrack != nil) {
                    videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width / 4.0, height: self.view.frame.size.height / 4.0)
                    if orientation == UIInterfaceOrientation.landscapeLeft || orientation == UIInterfaceOrientation.landscapeRight {
                        videoRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.height / 4.0, height: self.view.frame.size.width / 4.0)
                    }
                }
                let videoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
                self.localViewWidthConstraint!.constant = videoFrame.size.width
                self.localViewHeightConstraint!.constant = videoFrame.size.height
                if (self.remoteVideoTrack != nil) {
                    self.localViewBottomConstraint!.constant = 28.0
                    self.localViewRightConstraint!.constant = 28.0
                }
                else{
                    self.localViewBottomConstraint!.constant = containerHeight/2.0 - videoFrame.size.height/2.0
                    self.localViewRightConstraint!.constant = containerWidth/2.0 - videoFrame.size.width/2.0
                }
            }
            else if videoView == self.remoteView {
                self.remoteVideoSize = size
                let aspectRatio: CGSize = size.equalTo(CGSize.zero) ? defaultAspectRatio : size
                let videoRect: CGRect = self.view.bounds
                var videoFrame: CGRect = AVMakeRect(aspectRatio: aspectRatio, insideRect: videoRect)
                if self.isZoom {
                    let scale: CGFloat = max(containerWidth / videoFrame.size.width, containerHeight / videoFrame.size.height)
                    videoFrame.size.width *= scale
                    videoFrame.size.height *= scale
                }
                self.remoteViewTopConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
                self.remoteViewBottomConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
                self.remoteViewLeftConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
                self.remoteViewRightConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
            }
            self.view.layoutIfNeeded()
        })
        
    }
    
    func remoteDisconnected(){
        self.remoteVideoTrack?.remove(self.remoteView!)
        self.remoteView?.renderFrame(nil)
        if self.localVideoSize != nil {
            self.videoView(self.localView!, didChangeVideoSize: self.localVideoSize!)
        }
    }

}

