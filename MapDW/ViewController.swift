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
    
    var lats = [Double] (count: 3, repeatedValue: 42.4817457)
    var longs = [Double] (count: 3, repeatedValue: -71.2149056)
    
    var markers = [GMSMarker]()
    
    let updateFreq: Double = 4
    
    var xP=0.0
    var yP=0.0
    
    var mapView:GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let query = PFQuery(className:"TestObject")
        query.whereKey("uuid", equalTo:uuid)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                if(objects!.count == 0){
                    let newObject = PFObject(className:"TestObject")
                    newObject["uuid"] = self.uuid
                    newObject["xP"] = self.xP
                    newObject["yP"] = self.yP
                    newObject.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            // The object has been saved.
                        } else {
                            // There was a problem, check error.description
                        }
                    }
                }else{
                    self.updateXY()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        // GOOGLE MAP
        // draw the map
        let camera = GMSCameraPosition.cameraWithLatitude(fixLat,
            longitude: fixLong, zoom: 19.5)
        mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        mapView.animateToBearing(63)
        self.view = mapView
        
        // draw the personal markers
        markers.append(GMSMarker())
        markers.append(GMSMarker())
        markers.append(GMSMarker())
        markers[0].icon = GMSMarker.markerImageWithColor(UIColor.blueColor())
        markers[0].position = CLLocationCoordinate2DMake(lats[0], longs[0])
        markers[0].title = "Me"
        markers[0].snippet = "Shopper"
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
        updateXY()
        let lower : UInt32 = 0
        let upper : UInt32 = 4
        self.xP = Double(arc4random_uniform(upper - lower) + lower)
        self.yP = Double(arc4random_uniform(upper - lower) + lower)
        lats[0] = fixLat + (yP-1)/8500
        longs[0] = fixLong + (xP-1)/8000
        markers[0].position = CLLocationCoordinate2DMake(lats[0], longs[0])
        reloadOtherMarker()
    }
    
    func reloadOtherMarker(){
        let query = PFQuery(className:"TestObject")
        query.whereKey("uuid", notEqualTo:self.uuid)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // Do something with the found objects
                if let objects = objects {
                    var count = 1
                    for object in objects {
                        let nXP = object["xP"] as! Double
                        let nYP = object["yP"] as! Double
                        self.lats[count] = self.fixLat + (nYP-1)/8500
                        self.longs[count] = self.fixLong + (nXP-1)/8000
                        self.markers[count].position = CLLocationCoordinate2DMake(self.lats[count], self.longs[count])
                        self.markers[count].title = object.objectId
                        self.markers[count].snippet = "Assistant"
                        self.markers[count].map=self.mapView
                        count++
                        if(count>2){
                            break;
                        }

                    }
                    while(count<3){
                        self.markers[count].map=nil
                        count++
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func updateXY(){
        let query = PFQuery(className:"TestObject")
        query.whereKey("uuid", equalTo:self.uuid)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["xP"] = self.xP
                        object["yP"] = self.yP
                        object.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                            } else {
                                // There was a problem, check error.description
                            }
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
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

