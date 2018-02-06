//
//  ViewController.swift
//  HQcy Broadcaster (iOS)
//
//  Created by Ryan Campbell on 1/14/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit
import AVFoundation

class RTCVideoChatViewController: UIViewController, ARDAppClientDelegate, RTCEAGLVideoViewDelegate {
    var client: ARDAppClient?
    @IBOutlet var remoteView: RTCEAGLVideoView!
    @IBOutlet var localView: RTCEAGLVideoView!
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    
    override func viewDidLoad() {
        /* Initializes the ARDAppClient with the delegate assignment */
        client = ARDAppClient(delegate: self)

        /* RTCEAGLVideoViewDelegate provides notifications on video frame dimensions */
        remoteView.delegate = self
        localView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.localViewBottomConstraint?.constant=0.0
        self.localViewRightConstraint?.constant=0.0
        self.localViewHeightConstraint?.constant=self.view.frame.size.height
        self.localViewWidthConstraint?.constant=self.view.frame.size.width
        self.footerViewBottomConstraint?.constant=0.0
        self.disconnect()
        self.client=ARDAppClient(delegate: self)
        //self.client?.serverHostUrl="https://apprtc.appspot.com"
        var settingsModel = ARDSettingsModel()
        client!.connectToRoom(withId: self.roomName! as String!, settings: settingsModel, isLoopback: false, isAudioOnly: false, shouldMakeAecDump: false, shouldUseLevelControl: false)
        
        //self.client!.connectToRoom(withId: self.roomName! as String, options: nil)
        self.urlLabel?.text=self.roomName! as String
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        NotificationCenter.default.removeObserver(self)
        self.disconnect()
    }
    
    override var  shouldAutorotate : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    func applicationWillResignActive(_ application:UIApplication){
        self.disconnect()
    }
    
    func orientationChanged(_ notification:Notification){
        if let _ = self.localVideoSize {
            self.videoView(self.localView!, didChangeVideoSize: self.localVideoSize!)
        }
        if let _ = self.remoteVideoSize {
            self.videoView(self.remoteView!, didChangeVideoSize: self.remoteVideoSize!)
        }
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func audioButtonPressed (_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        self.client?.toggleAudioMute()
    }
    @IBAction func videoButtonPressed(_ sender:UIButton){
        sender.isSelected = !sender.isSelected
        self.client?.toggleVideoMute()
    }
    
    @IBAction func hangupButtonPressed(_ sender:UIButton){
        self.disconnect()
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    func disconnect(){
        if let _ = self.client{
            self.localVideoTrack?.remove(self.localView!)
            self.remoteVideoTrack?.remove(self.remoteView!)
            self.localView?.renderFrame(nil)
            self.remoteView?.renderFrame(nil)
            self.localVideoTrack=nil
            self.remoteVideoTrack=nil
            self.client?.disconnect()
        }
    }
    
    func remoteDisconnected(){
        self.remoteVideoTrack?.remove(self.remoteView!)
        self.remoteView?.renderFrame(nil)
        if self.localVideoSize != nil {
            self.videoView(self.localView!, didChangeVideoSize: self.localVideoSize!)
        }
    }
    
    func toggleButtonContainer() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            if (self.buttonContainerViewLeftConstraint!.constant <= -40.0) {
                self.buttonContainerViewLeftConstraint!.constant=20.0
                self.buttonContainerView!.alpha=1.0;
            }
            else {
                self.buttonContainerViewLeftConstraint!.constant = -40.0;
                self.buttonContainerView!.alpha=0.0;
            }
            self.view.layoutIfNeeded();
        })
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
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(RTCVideoChatViewController.updateUIForRotation), object: nil)
        // Hack for rotation to get the right video size
        self.perform(#selector(RTCVideoChatViewController.updateUIForRotation), with: nil, afterDelay: 0.2)
    }
    
    public func appClient(_ client: ARDAppClient!, didGetStats stats: [Any]!) {
        
    }
    
    public func appClient(_ client: ARDAppClient!, didChange state: RTCIceConnectionState) {
        
    }
    
    func updateUIForRotation(){
        let statusBarOrientation:UIInterfaceOrientation = UIApplication.shared.statusBarOrientation;
        let deviceOrientation:UIDeviceOrientation  = UIDevice.current.orientation
        if (statusBarOrientation.rawValue==deviceOrientation.rawValue){
            if let  _ = self.localVideoSize {
                self.videoView(self.localView!, didChangeVideoSize: self.localVideoSize!)
            }
            if let _ = self.remoteVideoSize {
                self.videoView(self.remoteView!, didChangeVideoSize: self.remoteVideoSize!)
            }
        }
        else{
            print("Unknown orientation Skipped rotation");
        }
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
                self.remoteViewTopConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
                self.remoteViewBottomConstraint!.constant = (containerHeight / 2.0 - videoFrame.size.height / 2.0)
                self.remoteViewLeftConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
                self.remoteViewRightConstraint!.constant = (containerWidth / 2.0 - videoFrame.size.width / 2.0)
            }
            self.view.layoutIfNeeded()
        })
        
    }
}
