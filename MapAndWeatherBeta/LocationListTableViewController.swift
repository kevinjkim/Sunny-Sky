//
//  LocationListTableViewController.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/25/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//


/* Things to Improve
UI Design
*/

import UIKit

class LocationListTableViewController: UITableViewController, LocationViewControllerDelegate {
    
    var locationNameArray = [String]()
    var locationLatArray = [String]()
    var locationLongArray = [String]()
    var isEditingTableCell: Bool = false
    var weatherLoaded: Bool = false
    
    var weeklyWeather: [DailyWeather] = []
    var currentWeather: CurrentWeather?
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        
        
        if let storedNames = NSUserDefaults.standardUserDefaults().objectForKey("nameArray") as? [String], let storedLats = NSUserDefaults.standardUserDefaults().objectForKey("latArray") as? [String], let storedLongs = NSUserDefaults.standardUserDefaults().objectForKey("longArray") as? [String] {
            self.locationNameArray = storedNames
            self.locationLatArray = storedLats
            self.locationLongArray = storedLongs
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
        allowSelections()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UI Functions
    
    func allowSelections() {
        tableView.allowsSelection = true
        navigationItem.rightBarButtonItem?.enabled = true
        navigationItem.leftBarButtonItem?.enabled = true
    }
    
    func disableSelections() {
        tableView.allowsSelection = false
        navigationItem.rightBarButtonItem?.enabled = false
        navigationItem.leftBarButtonItem?.enabled = false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationLongArray.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AnyObject = tableView.dequeueReusableCellWithIdentifier("LocationCell", forIndexPath: indexPath)

        cell.textLabel?!.text = locationNameArray[indexPath.row]

        return cell as! UITableViewCell
    }
    


    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {  // To delete Row
        return true
    }
    


    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            deleteArrayDataAtIndexPath(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    

    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let (nameToMove, latToMove, longToMove) = deleteArrayDataAtIndexPath(fromIndexPath.row)
        insertArrayDataAtIndexPath(toIndexPath.row, name: nameToMove, lat: latToMove, long: longToMove)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let selectedCell = tableView.cellForRowAtIndexPath(indexPath) {
            getCompleteWeather(forCellIndexPath: indexPath)
            
            disableSelections()
            
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
            activityIndicator.color = UIColor.blackColor()
            selectedCell.accessoryView = activityIndicator
            activityIndicator.startAnimating()
        }
    }


    
    func insertArrayDataAtIndexPath(indexPath: Int, name: String, lat: String, long: String) {
        locationNameArray.insert(name, atIndex: indexPath)
        locationLatArray.insert(lat, atIndex: indexPath)
        locationLongArray.insert(long, atIndex: indexPath)
        saveArrays()
    }
    
    func deleteArrayDataAtIndexPath(indexPath: Int) -> (name: String, lat: String, long: String) {
        let name = locationNameArray.removeAtIndex(indexPath)
        let lat = locationLatArray.removeAtIndex(indexPath)
        let long = locationLongArray.removeAtIndex(indexPath)
        saveArrays()
        return (name, lat, long)
    }
    
    // MARK : - Edit Functions
    @IBAction func editButtonPressed(sender: UIBarButtonItem) {
        if isEditingTableCell {                                     // user is editing and wants to stop
            isEditingTableCell = false
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.enabled = true
            let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editButtonPressed:")
            navigationItem.leftBarButtonItem = editButton
        } else {                                                    // user is not editing and wants to start
            isEditingTableCell = true
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.enabled = false
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "editButtonPressed:")
            navigationItem.leftBarButtonItem = doneButton
        }
    }
    

    func deleteAll() {
        locationNameArray.removeAll()
        locationLatArray.removeAll()
        locationLongArray.removeAll()
        saveArrays()
    }

    // MARK: - Weather Data Functions
    func getCompleteWeather(forCellIndexPath indexPath: NSIndexPath) {
        let forecastAPIKey = ""  //Enter Dark Sky API Key Here//
        let forecastService = ForecastService(apiKey: forecastAPIKey)
        let timeZoneService = TimeZoneService()
        timeZoneService.getTimeZoneForCoordinates(locationLatArray[indexPath.row], long: locationLongArray[indexPath.row]) { (let timeZone) -> Void in
            if let validTimeZone = timeZone {
                forecastService.getCurrentWeatherForLocation(self.locationLatArray[indexPath.row], long: self.locationLongArray[indexPath.row], timezone: validTimeZone, completion: { (let forecast) -> Void in
                    if let forecastWeather = forecast, let currentWeather = forecast?.currentWeather {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.weeklyWeather = forecastWeather.weeklyWeather
                            self.currentWeather = currentWeather
                            
                            self.activityIndicator.stopAnimating()
                            self.performSegueWithIdentifier("showWeather", sender: self)
                        }
                    } else {
                        print("Internet for timezone but not weather?")
                        
                    }
                })
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.allowSelections()
                    
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    
                    let ac = UIAlertController(title: "Error", message: "Could not establish network connection", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (_) -> Void in
                    })
                    ac.addAction(ok)
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Segue Functions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "addLocation" {
            let mapLocationVC = segue.destinationViewController as! LocationViewController
            mapLocationVC.delegate = self
        } else if segue.identifier == "showWeather" {
            let weatherVC = segue.destinationViewController as! WeatherTableViewController
            if let row = tableView.indexPathForSelectedRow?.row {
                weatherVC.userWeatherLatitude = locationLatArray[row]
                weatherVC.userWeatherLongitude = locationLongArray[row]
                weatherVC.locationName = locationNameArray[row]
                weatherVC.weeklyWeather = self.weeklyWeather
                weatherVC.preloadedCurrentWeather = self.currentWeather
            }
        }
    }
    
    // MARK: - Delegate Functions
    
    func addLocationNameAndCoordinates(name: String, lat: String, long: String) {
        locationNameArray.append(name)
        locationLatArray.append(lat)
        locationLongArray.append(long)
        saveArrays()
    }
    
    func saveArrays() {
        NSUserDefaults.standardUserDefaults().setObject(locationNameArray, forKey: "nameArray")
        NSUserDefaults.standardUserDefaults().setObject(locationLatArray, forKey: "latArray")
        NSUserDefaults.standardUserDefaults().setObject(locationLongArray, forKey: "longArray")
    }

}
