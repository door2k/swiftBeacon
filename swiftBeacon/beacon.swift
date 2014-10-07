//
//  beacon.swift
//  swiftBeacon
//
//  Created by Tamir Berliner on 10/7/14.
//  Copyright (c) 2014 Tamir Berliner. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation


//
//////////// HIGHLY IMPORTANT //////////////
// using beacons require the system to allow getting location while in background
// to do so you must go to the File manager -> Supporting Files --> info.plist.
// On the first item (Information Property List add NSLocationAlwaysUsageDescription as string
// and set it's value to the string that will pop up to the user.
// 
// CREDIT for beacon code + complete instructions:
// http://ibeaconmodules.us/blogs/news/14702963-tutorial-swift-based-ibeacon-app-development-with-corelocation-on-apple-ios-7-8
//

func ==(lhs: beacon, rhs: beacon) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class beacon : Hashable {
    var uuid:String = ""
    var identifier:String = ""
    var minor = 0
    var major = 0
    
    init (uuid: String, identifier:String = "beaconLib") {
        self.uuid = uuid
        self.identifier = identifier
        self.major = 0
        self.minor = 0
    }
    
    var hashValue: Int {
        get {
            return self.uuid.hashValue
        }
    }
    
}

class beaconHandler : NSObject, CLLocationManagerDelegate {
    var list:[beacon] = []
    var beaconDictionary:[beacon:Int] = [:]
    var locationManager: CLLocationManager?
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        if(locationManager!.respondsToSelector("requestAlwaysAuthorization")) {
            locationManager!.requestAlwaysAuthorization()
        }
        
        locationManager!.delegate = self
        locationManager!.pausesLocationUpdatesAutomatically = false
    }
    
    func register () {
        for currBeacon in list {
            NSLog(currBeacon.uuid)
            
            var region: CLBeaconRegion = CLBeaconRegion(proximityUUID:  NSUUID(UUIDString: currBeacon.uuid), identifier:     currBeacon.identifier)
            
            locationManager!.startMonitoringForRegion(region)
            locationManager!.startRangingBeaconsInRegion(region)
        }
    }
    
    func add (newBeacon : beacon) {
        if beaconDictionary[newBeacon] == nil {
            self.list += [newBeacon]
            beaconDictionary[newBeacon] = 0
        }
    }
}

extension beaconHandler: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager!,
        didRangeBeacons beacons: [AnyObject]!,
        inRegion region: CLBeaconRegion!) {
            
            var gotReport:Bool = false
              
            for (currBeacon: beacon) in self.list {
                if (currBeacon.identifier == region.identifier) {
                    let prevState = self.beaconDictionary[currBeacon]
                    self.beaconDictionary[currBeacon] = 0
                    for visibleBeacon in beacons {
                        var s: NSString = visibleBeacon.proximityUUID.description
                        if currBeacon.uuid == s.substringFromIndex(s.length - 36) &&
                            (visibleBeacon.proximity == CLProximity.Near ||
                             visibleBeacon.proximity == CLProximity.Immediate ||
                             visibleBeacon.proximity == CLProximity.Far)
                        {
                            currBeacon.minor = visibleBeacon.minor
                            currBeacon.major = visibleBeacon.major
                            
                            self.beaconDictionary[currBeacon] = 1
                            
                            if prevState == 0 {
                                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "beaconVisible", object: currBeacon))
                                gotReport = true
                            }
                        }
                    }
                    
                    if prevState == 1 && self.beaconDictionary[currBeacon] == 0 {
                        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "beaconDisappeared", object: currBeacon))
                        gotReport = true
                    }
                }
            }
            
            if gotReport {
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "beaconsUpdate", object: nil))
            }
    }
}
