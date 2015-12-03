//
//  ViewController.swift
//  MapDW
//
//  Created by jing zou on 11/30/15.
//  Copyright © 2015 JingZou. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse


class ViewController: UIViewController, EILIndoorLocationManagerDelegate {

    let locationManager = EILIndoorLocationManager()
    var location: EILLocation!
    
    let uuid = NSUUID().UUIDString
    
    let fixLat: Double = 42.4817457
    let fixLong: Double = -71.2149056
    
    var lats = [Double] (count: 3, repeatedValue: 0)
    var longs = [Double] (count: 3, repeatedValue: 0)
    
    var markers = [GMSMarker](count: 3, repeatedValue: GMSMarker())
    
    let updateFreq: Double = 0.1
    
    var xP=0.0
    var yP=0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // PARSE TEST
        //        let testObject = PFObject(className: "TestObject")
        //        testObject["foo"] = "bar"
        //        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
        //            print("Object has been saved.")
        //        }
        
        
        // GOOGLE MAP
        // draw the map
        let camera = GMSCameraPosition.cameraWithLatitude(fixLat,
            longitude: fixLong, zoom: 19.5)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.animateToBearing(63)
        self.view = mapView
        
        // draw the personal markers
        lats[0] = fixLat + xP/1000
        longs[0] = fixLong + yP/1000
        markers[0].icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        markers[0].position = CLLocationCoordinate2DMake(lats[0], longs[0])
        markers[0].map = mapView
        
        
        // MARKER UPDATE TIMER
        NSTimer.scheduledTimerWithTimeInterval(updateFreq, target: self, selector: "reloadMarker", userInfo: nil, repeats: true)
        
        
        // BEACON LOCATION INDDOR SDK
        self.locationManager.delegate = self
        
        ESTConfig.setupAppID("dwmap-csh", andAppToken: "2ef072d2ceceab171502e46684a50ffc")
        
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "sacks")
        fetchLocationRequest.sendRequestWithCompletion { (location, error) in
            if location != nil {
                self.location = location!
                self.locationManager.startPositionUpdatesForLocation(self.location)
            } else {
                print("can't fetch location: \(error)")
            }
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // RELOAD MARKER
    func reloadMarker() {
        lats[0] = fixLat + (yP-1)/8500
        longs[0] = fixLong + (xP-1)/8000
        markers[0].position = CLLocationCoordinate2DMake(lats[0], longs[0])
    }

    
    // INDOOR SDK
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didFailToUpdatePositionWithError error: NSError!) {
            print("failed to update position: \(error)")
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didUpdatePosition position: EILOrientedPoint!,
        withAccuracy positionAccuracy: EILPositionAccuracy,
        inLocation location: EILLocation!) {
            
            xP = position.x
            yP = position.y
            
            var accuracy: String!
            switch positionAccuracy {
            case .VeryHigh: accuracy = "+/- 1.00m"
            case .High:     accuracy = "+/- 1.62m"
            case .Medium:   accuracy = "+/- 2.62m"
            case .Low:      accuracy = "+/- 4.24m"
            case .VeryLow:  accuracy = "+/- ? :-("
            }
            print(String(format: "x: %5.2f, y: %5.2f, orientation: %3.0f, accuracy: %@",
                position.x, position.y, position.orientation, accuracy))
    }

}

