//
//  WeatherTableViewController.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/26/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//


import UIKit

class WeatherTableViewController: UITableViewController {
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var precipitationLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var userWeatherLatitude = String()
    var userWeatherLongitude = String()
    var locationName = String()
    
    let forecastAPIKey = "" //Enter Dark Sky API Key Here//

    
    var weeklyWeather: [DailyWeather] = []
    var preloadedCurrentWeather: CurrentWeather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(netHex: 0x5c9eff)
        tableView.rowHeight = 65.0
        
        if let verifiedWeather = preloadedCurrentWeather {
            updateUIWithCurrentWeather(verifiedWeather)
        }
        
        setRefreshControl()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - View Functions
    
    func updateUIWithCurrentWeather(curWeather: CurrentWeather) {
        self.locationNameLabel.text = self.locationName
        self.iconImage.image = curWeather.icon
        self.currentTemperatureLabel.text = "\(curWeather.temperature)º"
        self.humidityLabel.text = "Humidity: \(curWeather.humidity)%"
        self.precipitationLabel.text = "Rain Chance: \(curWeather.precipProbability)%"

        if let maxTemp = weeklyWeather.first?.maxTemperature, let minTemp = weeklyWeather.first?.minTemperature, let dayString = weeklyWeather.first?.day {
            self.maxTempLabel.text = "\(maxTemp)º"
            self.minTempLabel.text = "\(minTemp)º"
            self.dayLabel.text = dayString
        }
        
    }
    
    func setRefreshControl() {
        let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.refreshControl?.addTarget(self, action: "getCompleteWeather", forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to Refresh", attributes: attributes)
        self.refreshControl?.tintColor = UIColor.whiteColor()
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyWeather.count-1
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("weatherCell", forIndexPath: indexPath) as! WeatherTableViewCell
        cell.selectionStyle = .None
        
        if indexPath.row % 2 == 0{
            cell.backgroundColor = UIColor(netHex: 0x86aaff)
        } else {
            cell.backgroundColor = UIColor(netHex: 0x3a64ff)
        }
        
        let dayInt = indexPath.row + 1
        
        cell.iconImageView.image = weeklyWeather[dayInt].icon
        cell.dayLabel.text = weeklyWeather[dayInt].day
        cell.maxTempLabel.text = "High: \(weeklyWeather[dayInt].maxTemperature)º"
        cell.minTempLabel.text = "Low: \(weeklyWeather[dayInt].minTemperature)º"
        cell.summaryLabel.text = weeklyWeather[dayInt].summary
        
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    

    // MARK: - Weather Data Functions
    
    func getCompleteWeather() {
        let forecastService = ForecastService(apiKey: forecastAPIKey)
        let timeZoneService = TimeZoneService()
        timeZoneService.getTimeZoneForCoordinates(userWeatherLatitude, long: userWeatherLongitude) { (let timeZone) -> Void in
            if let validTimeZone = timeZone {
            
                forecastService.getCurrentWeatherForLocation(self.userWeatherLatitude, long: self.userWeatherLongitude, timezone: validTimeZone) { (let forecast) -> Void in
                    if let forecastWeather = forecast, let currentWeatherData = forecast?.currentWeather {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.updateUIWithCurrentWeather(currentWeatherData)
                            self.weeklyWeather = forecastWeather.weeklyWeather
                            self.tableView.reloadData()
                            print("DONE")
                            self.refreshControl?.endRefreshing()
                        }
                    } else {
                        print("Internet for timezone but not weather?")
                    }
                }
            } else {
                dispatch_async(dispatch_get_main_queue()) {
                    let ac = UIAlertController(title: "Error", message: "Could not establish network connection", preferredStyle: .Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (_) -> Void in
                    })
                    ac.addAction(ok)
                    self.presentViewController(ac, animated: true, completion: nil)
                    self.refreshControl?.endRefreshing()
                }
            }
        }

    }

}

// MARK: - UIColor Extensions

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
    convenience init(netHex: Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}
