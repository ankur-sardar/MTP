//
//  ViewController.swift
//  closest-beacon-demo
//
//  Created by Will Dages on 10/11/14.
//  @willdages on Twitter
//

import UIKit
import CoreLocation
//let id = "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6"
let id = "2f234454-cf6d-4a04-adf2-f4911ba9ffa6"
//let ipAddr = "10.7.6.211"
let ipAddr = "192.168.43.71"
let port = 10000

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let region = CLBeaconRegion(proximityUUID: UUID(uuidString: "2f234454-cf6d-4a04-adf2-f4911ba9ffa6")!, identifier: "Estimotes")
    // Note: make sure you replace the keys here with your own beacons' Minor Values
    let colors = [
        2: UIColor(red: 84/255, green: 77/255, blue: 160/255, alpha: 1),
        3: UIColor(red: 142/255, green: 212/255, blue: 220/255, alpha: 1),
        4: UIColor(red: 162/255, green: 213/255, blue: 181/255, alpha: 1)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse) {
            locationManager.requestWhenInUseAuthorization()

        }
        locationManager.startRangingBeacons(in: region)
        print("ok")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        print(beacons[0].minor)
        let id = beacons[0].minor
        //    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons)
        let knownBeacons = beacons.filter{ $0.proximity != CLProximity.unknown }
        if (knownBeacons.count > 0) {
            let closestBeacon = knownBeacons[0] as CLBeacon
            self.view.backgroundColor = self.colors[closestBeacon.minor.intValue]
        }
        let url = NSURL(string: "http://\(ipAddr):\(port)/rec/\("1")/\(id))")!
        let request = URLRequest(url: url as URL)
        let session = URLSession.shared
        //        let time = NSDate().timeIntervalSince1970
        let dataTask = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            print("done, \(id) error: \(error) ")
        }
        dataTask.resume()

    }
    
}

