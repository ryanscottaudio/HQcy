//
//  AppDelegate.swift
//  HQcy Broadcaster
//
//  Created by Ryan Campbell on 1/5/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import Cocoa

func setTimeout(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

let socketUrl = "https://shrouded-oasis-46595.herokuapp.com/"
let videoUrl = "rmtp://enigmatic-everglades-44073.herokuapp.com/live/"
let streamName = "video"

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

