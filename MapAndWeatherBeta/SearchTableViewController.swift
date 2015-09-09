//
//  SearchTableViewController.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 8/12/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

// WORK ON
// UI
// Attributed Text


import UIKit
import MapKit


class SearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var delegate: LocationViewControllerDelegate?
    
    let autocomplete = AutocompleteService()
    var searchController = UISearchController()
    
    var autocompletePredicitons: [String] = []
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    // MARK: - Search Functions
    
    func setUpSearchBar() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.placeholder = "Enter location"
        searchController.searchBar.barTintColor = UIColor(netHex: 0x3386ff)
        
        let cancelButtonAttributes: [String: AnyObject] = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, forState: .Normal)
        
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.reloadData()
        
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if searchController.searchBar.text?.characters.count > 0 && searchController.searchBar.text != nil {
            startStatusBarActivityIndicator()
            let intendedText = searchController.searchBar.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
            autocomplete.getPredicitonsForText(intendedText!) { (let currentPredictions) -> Void in
                if currentPredictions != nil {
                    if currentPredictions?.first == "STATUS ERROR" {  // STATUS NOT OK
                        dispatch_async(dispatch_get_main_queue()) {
                            self.autocompletePredicitons.removeAll()
                            self.tableView.reloadData()
                            self.stopStatusBarActivityIndicator()
                        }
                    } else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.autocompletePredicitons = currentPredictions!
                            self.tableView.reloadData()
                            self.stopStatusBarActivityIndicator()
                        }
                    }
                } else {  // predicitons is nil -- no network
                    dispatch_async(dispatch_get_main_queue()) {
                        self.searchController.active = false
                        self.printAlert("Could not establish network connection")
                    }
                }
            }
        } else {
            autocompletePredicitons = []
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var sectionNumber = 0
        if autocompletePredicitons.count > 0 {
            tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            sectionNumber = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, tableView.bounds.size.width, tableView.bounds.size.height))
            noDataLabel.text = "No Results"
            noDataLabel.textColor = UIColor.blackColor()
            noDataLabel.textAlignment = NSTextAlignment.Center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        }
        return sectionNumber
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompletePredicitons.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = autocompletePredicitons[indexPath.row]
        
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        selectedCell?.accessoryView = activityIndicator
        activityIndicator.color = UIColor.blackColor()
        activityIndicator.startAnimating()
        
        let locationName = autocompletePredicitons[indexPath.row]
        getCoordinateForString(locationName)
    }
    
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: - Geocode String Functions
    
    func getCoordinateForString(location: String) {
        CLGeocoder().geocodeAddressString(location) { (placemarks, error) -> Void in
            if error == nil {
                if let placeCoordinate = placemarks?[0].location?.coordinate {
                    self.searchController.searchBar.resignFirstResponder()
                    self.searchController.active = false
                    let locationLat = "\(placeCoordinate.latitude)"
                    let locationLong = "\(placeCoordinate.longitude)"
                    let locationName = self.removeUnitedStatesFromString(location)
                    self.delegate?.addLocationNameAndCoordinates(locationName, lat: locationLat, long: locationLong)
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    self.activityIndicator.stopAnimating()
                    self.searchController.searchBar.resignFirstResponder()
                }
            }
        }
    }
    
    func removeUnitedStatesFromString(text: String) -> String {
        if text.rangeOfString("United States") != nil {  // Contains United States
            let index1 = advance(text.endIndex, -15)
            return text.substringToIndex(index1)
        }
        return text
    }
    
    // MARK: - Activity Indicator Functions
    
    func startStatusBarActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func stopStatusBarActivityIndicator() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    
    // MARK: - Alert Functions
    
    func printAlert(alertMessage: String) {
        let alertController = UIAlertController(title: "Error", message: alertMessage, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "OK", style: .Default) { (_) -> Void in
        }
        alertController.addAction(ok)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}