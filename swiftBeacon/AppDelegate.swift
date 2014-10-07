//
//  AppDelegate.swift
//  swiftBeacon
//
//  Created by Tamir Berliner on 9/29/14.
//  Copyright (c) 2014 Tamir Berliner. All rights reserved.
//

import UIKit
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    let uuidString = "B0702880-A295-A8AB-F734-031A98A512DE"
    let uuidString2 = "B0702880-A295-A8AB-F734-031A98A512DD"

    var hBeacons: beaconHandler = beaconHandler()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        hBeacons.add(beacon(uuid: uuidString, identifier: "living room (Mac mini)"))
        hBeacons.add(beacon(uuid: uuidString2, identifier: "laptop (Mac air)"))
        
        hBeacons.register()
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconVisible:", name: "beaconVisible", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconDisappeared:", name: "beaconDisappeared", object: nil)

        return true
    }
    
    func sendLocalNotificationWithMessage(message: String!) {
        //        NSLog("%@", "Sending message \(message)")
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
        
    func beaconVisible(notification: NSNotification) {
        sendLocalNotificationWithMessage("welcome to: \((notification.object as beacon).identifier)")
    }
        
    func beaconDisappeared(notification: NSNotification) {
        sendLocalNotificationWithMessage("by by from: \((notification.object as beacon).identifier)")
    }



    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

