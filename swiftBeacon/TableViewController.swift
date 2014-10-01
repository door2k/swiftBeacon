//
//  TableViewController.swift
//  swiftBeacon
//
//  Created by Tamir Berliner on 9/30/14.
//  Copyright (c) 2014 Tamir Berliner. All rights reserved.
//

import Foundation

//
//  ViewController.swift
//  swiftBeacon
//
//  Created by Tamir Berliner on 9/29/14.
//  Copyright (c) 2014 Tamir Berliner. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "beaconsRefresh:", name: "beaconsUpdate", object: nil)
        
        var myRefresh: UIRefreshControl = UIRefreshControl()
        myRefresh.addTarget(self, action: "refresh", forControlEvents:.ValueChanged)
        self.refreshControl = myRefresh
    }
    
    func refresh()
    {
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    func beaconsRefresh(notification: NSNotification){
        test()
    }
    
    func test()
    {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.tableView.reloadData()
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("in tableView number of rowsin section")
        return 5
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: (NSIndexPath!)) -> UITableViewCell {
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let aVariable = appDelegate.hBeacons
        
        NSLog("Handling cell: \(indexPath.row)")
        
        var cell = tableView.dequeueReusableCellWithIdentifier("beaconCell") as? UITableViewCell

        if indexPath.row < aVariable.list.count {
            cell?.textLabel?.text = "...\((aVariable.list[indexPath.row].uuid as NSString).substringFromIndex(16))"
            cell?.textLabel?.font = UIFont.systemFontOfSize(16)
            
            if aVariable.beaconDictionary[aVariable.list[indexPath.row]] == 1 {
                    cell?.textLabel?.font = UIFont.boldSystemFontOfSize(16)
            }
        } else {
            cell?.textLabel?.text = "no beacon \(indexPath.row)"
        }
        
//        cell?.textLabel?.text = "no beacon \(indexPath.row)"
        
        //var imageName = UIImage(named: transportItems[indexPath.row])
        //cell?.imageView?.image = imageName
        
        return cell!
    }
    
}

