//
//  AppDelegate.swift
//  HQcy
//
//  Created by Ryan Campbell on 1/3/18.
//  Copyright © 2018 Ryan Campbell. All rights reserved.
//

import UIKit

let baseUrl = "://localhost:"
let socketUrl = "http\(baseUrl)8080/"
let videoUrl = "rtmp\(baseUrl)1935/live/video"

let questionTime: TimeInterval = 10.0
let answerTime: TimeInterval = 3.0
let defaultColor = UIColor.white
let highlightedColor = UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0)
let selectedColor = UIColor(red:0.43, green:0.43, blue:0.82, alpha:1.0)
let correctColor = UIColor(red:0.33, green:0.78, blue:0.58, alpha:1.0)
let incorrectColor = UIColor(red:0.87, green:0.20, blue:0.42, alpha:1.0)

func setTimeout(_ seconds: Double, completion: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

