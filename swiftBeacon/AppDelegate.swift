//
//  AppDelegate.swift
//  swiftBeacon
//
//  Created by Tamir Berliner on 9/29/14.
//  Copyright (c) 2014 Tamir Berliner. All rights reserved.
//

import UIKit
import CoreLocation


class beacon {
    var uuid:String = ""
    var identifier:String = ""
    var beaconUUID:NSUUID?
    var region:CLBeaconRegion?
    
    init (uuid: String, identifier:String = "Xoom") {
        self.uuid = uuid
        self.identifier = identifier
    }

}

class beaconHandler {
    var list:[beacon] = []
    var beaconDictionary:[String:Int] = [:]
    
    func register (locationManager: CLLocationManager?) {
        for currBeacon in list {
            NSLog(currBeacon.uuid)
            
            var region: CLBeaconRegion = CLBeaconRegion(proximityUUID:  NSUUID(UUIDString: currBeacon.uuid), identifier:     currBeacon.identifier)
            
            locationManager!.startMonitoringForRegion(region)
            locationManager!.startRangingBeaconsInRegion(region)
            
        }

    }
    
    func add (newBeacon : beacon) {
        if beaconDictionary[newBeacon.uuid] == nil {
            self.list += [newBeacon]
            beaconDictionary[newBeacon.uuid] = 0
        }
    }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var locationManager: CLLocationManager?

    let uuidString = "B0702880-A295-A8AB-F734-031A98A512DE"
    let uuidString2 = "B0702880-A295-A8AB-F734-031A98A512DD"

    var hBeacons: beaconHandler = beaconHandler()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        hBeacons.add(beacon(uuid: uuidString, identifier: "test1"))
        hBeacons.add(beacon(uuid: uuidString2, identifier: "test2"))
        
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
//        
//        var tempbeacon: CLBeaconRegion = CLBeaconRegion(proximityUUID:  NSUUID(UUIDString: self.uuidString),
//                                                        identifier:     "test")
//        locationManager!.startMonitoringForRegion(tempbeacon)
//        locationManager!.startRangingBeaconsInRegion(tempbeacon)
        
        hBeacons.register(locationManager!)
        
        if(application.respondsToSelector("registerUserNotificationSettings:")) {
            application.registerUserNotificationSettings(
                UIUserNotificationSettings(
                    forTypes: UIUserNotificationType.Alert | UIUserNotificationType.Sound,
                    categories: nil
                )
            )
        }
        
//        application.applicationIconBadgeNumber = 0
        return true
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

var state = 0

extension AppDelegate: CLLocationManagerDelegate {
    
    func sendLocalNotificationWithMessage(message: String!) {
        NSLog("%@", "Sending message \(message)")
        let notification:UILocalNotification = UILocalNotification()
        notification.alertBody = message
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func locationManager(manager: CLLocationManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            
//            NSLog("didRangeBeacons");
            var message:String = ""
            var gotReport:Bool = false
            
            if(beacons.count > 0) {
                NSLog("beacons.count = \(beacons.count)")
            }
            
            for (currBeacon: beacon) in hBeacons.list {
                if (currBeacon.identifier == region.identifier) {
                    let prevState = hBeacons.beaconDictionary[currBeacon.uuid]
                    hBeacons.beaconDictionary[currBeacon.uuid] = 0 // start from "beacon not found" and set to 1 if found.
//                    NSLog("Examinig beacon: \(currBeacon.uuid)")
                    for visibleBeacon in beacons {
                        var s: NSString = visibleBeacon.proximityUUID.description
                        NSLog(s.substringFromIndex(s.length - 36))
                        if currBeacon.uuid == s.substringFromIndex(s.length - 36) {
                            hBeacons.beaconDictionary[currBeacon.uuid] = 1
                            if prevState == 0 {
                                message += "beacon: \(currBeacon.uuid) is visible\n"
                                gotReport = true
                            }
                        }
                    }
                    
                    if prevState == 1 && hBeacons.beaconDictionary[currBeacon.uuid] == 0 {
                        message += "beacon: \(currBeacon.uuid) is no longer visible\n"
                        gotReport = true
                    }
                }
            }
            
            if gotReport {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "beaconsUpdate", object: nil))
                NSLog("%@", message)
                sendLocalNotificationWithMessage(message)
            }
    }
}
