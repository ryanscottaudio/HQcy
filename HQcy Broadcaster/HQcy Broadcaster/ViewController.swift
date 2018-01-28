//
//  ViewController.swift
//  HQcy Broadcaster
//
//  Created by Ryan Campbell on 1/5/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import Cocoa
//import AVFoundation
//import VideoToolbox
//import HaishinKit
import SocketIO

class ViewController: NSViewController, NSWindowDelegate {

//    @IBOutlet var audioPopUpButton: NSPopUpButton!
//    @IBOutlet var cameraPopUpButton: NSPopUpButton!
//    @IBOutlet var broadcastButton: NSButton!
//    var isBroadcasting: Bool = false
//    var lfView: LFView!
//    let rtmpConnection: RTMPConnection = RTMPConnection()
//    var rtmpStream: RTMPStream!
    
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
        
//        startCamera()
        startSocket()
    }
    
//    func startCamera() {
//        rtmpStream = RTMPStream(connection: rtmpConnection)
//        rtmpStream.captureSettings = [
//            "fps": 30,
//            "sessionPreset": AVCaptureSession.Preset.low,
//            "continuousAutofocus": false,
//            "continuousExposure": false,
//        ]
//        rtmpStream.audioSettings = [
//            "muted": false,
//            "bitrate": 32 * 1024,
//            "sampleRate": 44_100,
//        ]
//        rtmpStream.videoSettings = [
//            "width": 180,
//            "height": 320,
//            "bitrate": 160 * 1024,
//            "profileLevel": kVTProfileLevel_H264_Baseline_3_1,
//            "maxKeyFrameIntervalDuration": 2,
//        ]
//        // 0 means the same as input
//        rtmpStream.recorderSettings = [
//            AVMediaType.audio: [
//                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                AVSampleRateKey: 0,
//                AVNumberOfChannelsKey: 0,
//            ],
//            AVMediaType.video: [
//                AVVideoCodecKey: AVVideoCodecType.h264,
//                AVVideoHeightKey: 0,
//                AVVideoWidthKey: 0,
//            ],
//        ]
//        rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
//
//        audioPopUpButton!.removeAllItems()
//        let audios: [Any]! = AVCaptureDevice.devices(for: .audio)
//        for audio in audios {
//            if let audio: AVCaptureDevice = audio as? AVCaptureDevice {
//                audioPopUpButton!.addItem(withTitle: audio.localizedName)
//            }
//        }
//
//        let defaultAudioLocalizedName = "Built-in Microphone"
//        let audioLocalizedName: String
//        if (audioPopUpButton.item(withTitle: defaultAudioLocalizedName) !== nil) {
//            audioLocalizedName = defaultAudioLocalizedName
//            audioPopUpButton.selectItem(withTitle: defaultAudioLocalizedName)
//        } else {
//            audioLocalizedName = audioPopUpButton.itemTitles[0]
//        }
//        rtmpStream.attachAudio(DeviceUtil.device(
//            withLocalizedName: audioLocalizedName,
//            mediaType: AVMediaType.audio.rawValue
//        ))
//
//        cameraPopUpButton!.removeAllItems()
//        let cameras: [Any]! = AVCaptureDevice.devices(for: .video)
//        for camera in cameras {
//            if let camera: AVCaptureDevice = camera as? AVCaptureDevice {
//                cameraPopUpButton!.addItem(withTitle: camera.localizedName)
//            }
//        }
//        rtmpStream.attachCamera(DeviceUtil.device(withLocalizedName: cameraPopUpButton.itemTitles[0], mediaType: AVMediaType.video.rawValue))
//
//        lfView = LFView(frame: view.frame)
//        lfView!.attachStream(rtmpStream)
//        view.addSubview(lfView, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
//    }
//
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
//        guard let keyPath: String = keyPath, Thread.isMainThread else {
//            return
//        }
//        switch keyPath {
//        case "currentFPS":
//            view.window!.title = "HaishinKit(FPS: \(rtmpStream.currentFPS): totalBytesIn: \(rtmpConnection.totalBytesIn): totalBytesOut: \(rtmpConnection.totalBytesOut))"
//        default:
//            break
//        }
//    }
//
//    func windowDidResize(_ notification: Notification) {
//        let size: CGSize! = view.window!.frame.size
//        lfView.frame = NSMakeRect(0, 0, size.width, size.height)
//    }
//
//    @IBAction func selectCamera(_ sender: NSPopUpButton) {
//        let device: AVCaptureDevice! = DeviceUtil.device(withLocalizedName:
//            cameraPopUpButton.itemTitles[cameraPopUpButton.indexOfSelectedItem], mediaType: AVMediaType.video.rawValue
//        )
//        rtmpStream.attachCamera(device)
//    }
//
//    @IBAction func selectAudio(_ sender: NSPopUpButton) {
//        let device: AVCaptureDevice! = DeviceUtil.device(withLocalizedName:
//            audioPopUpButton.itemTitles[audioPopUpButton.indexOfSelectedItem], mediaType: AVMediaType.audio.rawValue
//        )
//        rtmpStream.attachAudio(device)
//    }
//
//    @IBAction func broadcastOrStop(_ sender: NSButton) {
//        if isBroadcasting {
//            isBroadcasting = false
//            sender.title = "Broadcast"
//            cameraPopUpButton.isEnabled = true
//            audioPopUpButton.isEnabled = true
//            rtmpConnection.removeEventListener(Event.RTMP_STATUS, selector: #selector(ViewController.rtmpStatusHandler(_: )), observer: self)
//            rtmpConnection.close()
//        } else {
//            isBroadcasting = true
//            sender.title = "Stop"
//            cameraPopUpButton.isEnabled = false
//            audioPopUpButton.isEnabled = false
//            rtmpConnection.addEventListener(Event.RTMP_STATUS, selector: #selector(ViewController.rtmpStatusHandler(_: )), observer: self)
//            rtmpConnection.connect(videoUrl)
//        }
//    }
//
//    @objc func rtmpStatusHandler(_ notification: Notification) {
//        let e: Event = Event.from(notification)
//        guard
//            let data: ASObject = e.data as? ASObject,
//            let code: String = data["code"] as? String else {
//                return
//        }
//        switch code {
//        case RTMPConnection.Code.connectSuccess.rawValue:
//            rtmpStream!.publish(streamName)
//        default:
//            break
//        }
//    }
    
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
