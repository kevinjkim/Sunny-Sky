//
//  LocationViewController.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/25/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

// WORK ON
// USING GOOGLE MAP?
// Popover Info for Current Location

import UIKit
import MapKit

protocol LocationViewControllerDelegate {
    func addLocationNameAndCoordinates(name: String, lat: String, long: String)
}

class LocationViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var locationMapView: MKMapView?
    
    
    let locationManager = CLLocationManager()
    var delegate: LocationViewControllerDelegate?
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    var weatherLatitude: CLLocationDegrees = CLLocationDegrees()
    var weatherLongitude: CLLocationDegrees = CLLocationDegrees()
    
    var userLocation: CLLocationCoordinate2D? // nil if location not enabled
    var locationEnabled: Bool = false
    var mapViewNeedsUpdate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "viewIsActive", name: UIApplicationDidBecomeActiveNotification, object: nil)

        loadMapViewAndPermissions()
    }
    
    func viewIsActive() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationEnabled = true
            userLocation = locationManager.location?.coordinate
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Functions
    @IBAction func currentLocationPressed(sender: UIButton) {
        if locationEnabled {
            self.weatherLatitude = userLocation!.latitude
            self.weatherLongitude = userLocation!.longitude
            
            getStringNameFromCoordinates()
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enable location services in Settings", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (let action) -> Void in
            })
            let settingsAction = UIAlertAction(title: "Settings", style: .Default, handler: { (_) -> Void in
                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(settingsURL)
            })
            alertController.addAction(settingsAction)
            alertController.addAction(ok)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }


    
    // MARK: - Motion Functions
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if locationEnabled {
            let alertOptionController = UIAlertController(title: "Confirm", message: "Would you like to use your current location?", preferredStyle: .Alert)
            let no = UIAlertAction(title: "No", style: .Default, handler: { (_) -> Void in
                self.hideActivityIndicator()
            })
            let yes = UIAlertAction(title: "Yes", style: .Default, handler: { (_) -> Void in
                self.weatherLatitude = self.userLocation!.latitude
                self.weatherLongitude = self.userLocation!.longitude
                self.getStringNameFromCoordinates()
            })
            alertOptionController.addAction(no)
            alertOptionController.addAction(yes)
            presentViewController(alertOptionController, animated: true, completion: nil    )
            
            getStringNameFromCoordinates()
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enable location services in Settings", preferredStyle: .Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (let action) -> Void in
            })
            let settingsAction = UIAlertAction(title: "Settings", style: .Default, handler: { (_) -> Void in
                let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.sharedApplication().openURL(settingsURL)
            })
            alertController.addAction(settingsAction)
            alertController.addAction(ok)
            presentViewController(alertController, animated: true, completion: nil)
        }
    }

    
    // MARK: - Map Gesture Functions
    @IBAction func mapLocationLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let annotation = MKPointAnnotation()
            let pointTouched = sender.locationInView(self.locationMapView)
            if let pointCoordinate: CLLocationCoordinate2D = locationMapView?.convertPoint(pointTouched, toCoordinateFromView: self.locationMapView) {
                weatherLatitude = pointCoordinate.latitude
                weatherLongitude = pointCoordinate.longitude
                
                annotation.coordinate = pointCoordinate
                locationMapView?.addAnnotation(annotation)
                
                getStringNameFromCoordinates()
            } else {
                hideActivityIndicator()
                printAlert("Could not find map location")
            }
        }
    }
    
    // MARK: - Location/Permission Functions
    
    func loadMapViewAndPermissions() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationEnabled = true
            mapViewNeedsUpdate = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if mapViewNeedsUpdate{
            mapViewNeedsUpdate = false
            let latDelta: CLLocationDegrees = 0.01
            let lonDelta: CLLocationDegrees = 0.01
            let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            userLocation = locations[0].coordinate
            let mapLocation = CLLocationCoordinate2DMake(userLocation!.latitude, userLocation!.longitude)
            let region = MKCoordinateRegionMake(mapLocation, span)
            locationMapView?.setRegion(region, animated: true)
        }
        
    }
    
    // MARK: - String Functions
    
    func getStringNameFromCoordinates() {
        let location = CLLocation(latitude: weatherLatitude, longitude: weatherLongitude)
        showActivityIndicator()
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            if let placemarkLocation: AnyObject = placemarks?[0] {
                var name: String = ""
                if placemarkLocation.country == "United States" {
                    if let locale = placemarkLocation.locality, let admin = placemarkLocation.administrativeArea {
                        name = "\(locale), \(admin)"
                    } else {
                        print("Could not find locale/admin area")
                    }
                } else {
                    if let admin = placemarkLocation.administrativeArea, let country = placemarkLocation.country {
                        name = "\(admin), \(country)"
                    }
                }
                if name != "" {
                    self.delegate?.addLocationNameAndCoordinates(name, lat: "\(self.weatherLatitude)", long: "\(self.weatherLongitude)")
                    self.navigationController?.popToRootViewControllerAnimated(true)
                } else {
                    print("NO NAME")
                }
            } else {
                self.hideActivityIndicator()
                self.printAlert("Could not find location name")
            }
        }
    }
    
    // MARK: - Alert Functions
    
    func showActivityIndicator() {
        overlayView = UIView(frame: view.frame)
        overlayView.backgroundColor = UIColor.darkGrayColor()
        view.addSubview(overlayView)
        
        overlayView.addSubview(activityIndicator)
        activityIndicator.center = overlayView.center
        activityIndicator.color = UIColor.whiteColor()
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
        overlayView.removeFromSuperview()
    }
    
    func printAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { (_) -> Void in
        }
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Navigation Functions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSearch" {
            let destinationVC = segue.destinationViewController as! SearchTableViewController
            destinationVC.delegate = self.delegate
        }
    }
    
}

