# iOS-App
Proof of Concept: Beacon Location on Google Map in iOS-App with Demandware @ Brandeis University

####SDK
Please check the Podfile for the SDK we installed. Noted, the Parse/Bolt library spec is not updated on CocoaPods so you might need to manually installed them.

####Critical Code
Link Parse API and Google Map API in `func didFinishLaunchingWithOptions()`at `AppDelegate.swift`:
```
// Initialize Parse.
Parse.setApplicationId("JFXj6skkhZEDFuNnGYLm7pajgPRIy11QElUi6wv8",
clientKey: "vKDMPDXXE0Le7ff5BDvPfXIz0qQkIYZWbbN0TAKE")  // KEY and Token

// GOOGLE MAP
GMSServices.provideAPIKey("AIzaSyAyQlurFCt6lkcpg60bGkvs9UkToqcK1xc")  // API KEY
```

In `ViewController.swift`, we setup the Estimote Indoor Location Manager and its delgated function:
```
let locationManager = EILIndoorLocationManager()
var location: EILLocation!

func indoorLocationManager(manager: EILIndoorLocationManager!,
    didFailToUpdatePositionWithError error: NSError!) {
        print("failed to update position: \(error)")
}

func indoorLocationManager(manager: EILIndoorLocationManager!,
    didUpdatePosition position: EILOrientedPoint!,
    withAccuracy positionAccuracy: EILPositionAccuracy,
    inLocation location: EILLocation!) {
        
        self.xP = position.x
        self.yP = position.y
        
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
```
and then we can setup the fetcher to get an Location objcet, which we contains the x, y coordinate and orientation:
```
self.locationManager.delegate = self

ESTConfig.setupAppID("dwmap-csh", andAppToken: "2ef072d2ceceab171502e46684a50ffc")  // app identifier and token

let fetchLocationRequest = EILRequestFetchLocation(locationIdentifier: "volen") // configuration identifier

// fetching location
fetchLocationRequest.sendRequestWithCompletion { (location, error) in
    if location != nil {
        self.location = location!
        self.locationManager.startPositionUpdatesForLocation(self.location)
    } else {
        print("can't fetch location: \(error)")
    }
}
```
Once we have the x, y coordinate, we will have a relative location in a space relative to all the beacons and if we have define longtitude and latitude for each beacons, we will have our actual longtitude and latitude on Earth. With such information, we can easitly draw markers on Google Map.

<img src="http://i.imgur.com/MIxwWgz.jpg" align="left" height="600" Hspace="30" Vspace="10">
