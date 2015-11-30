//
//  ViewController.swift
//  MapDW
//
//  Created by jing zou on 11/30/15.
//  Copyright © 2015 JingZou. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, EILIndoorLocationManagerDelegate {

    let locationManager = EILIndoorLocationManager()
    var location: EILLocation!
    
    var mySelfLat: Double = 0
    var mySelfLong: Double = 0
    var marker: GMSMarker = GMSMarker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let camera = GMSCameraPosition.cameraWithLatitude(42.4817457,
            longitude: -71.2149056, zoom: 19.5)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.animateToBearing(63)
        self.view = mapView
        
        
        NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "reloadMarker", userInfo: nil, repeats: true)
        
        marker = GMSMarker()
        marker.icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        mySelfLat = 42.4817457
        mySelfLong = -71.2149056
        marker.position = CLLocationCoordinate2DMake(mySelfLat, mySelfLong)
        marker.map = mapView
        
        
        self.locationManager.delegate = self
        
        ESTConfig.setupAppID("dwmap-csh", andAppToken: "2ef072d2ceceab171502e46684a50ffc")
        
        let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "my-kitchen")
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
    
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didFailToUpdatePositionWithError error: NSError!) {
            print("failed to update position: \(error)")
    }
    
    func indoorLocationManager(manager: EILIndoorLocationManager!,
        didUpdatePosition position: EILOrientedPoint!,
        withAccuracy positionAccuracy: EILPositionAccuracy,
        inLocation location: EILLocation!) {
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

    func reloadMarker() {
        //        marker.map = nil;
        mySelfLat = mySelfLat + 0.00001
        mySelfLong = mySelfLong + 0.00001
        marker.position = CLLocationCoordinate2DMake(mySelfLat, mySelfLong)
    }

}

