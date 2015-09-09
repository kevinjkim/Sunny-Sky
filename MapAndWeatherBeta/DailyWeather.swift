//
//  DailyWeather.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/28/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation
import UIKit

struct DailyWeather{
    let maxTemperature: Int
    let minTemperature: Int
    let precipProbability: Int
    let humidity: Int
    let summary: String
    let icon: UIImage
    var day: String = ""
    
    let dateFormatter = NSDateFormatter()
    let timeZoneService = TimeZoneService()
    
    init(weatherDictionary: [String: AnyObject], timezone: String) {
        self.maxTemperature = weatherDictionary["temperatureMax"] as! Int
        self.minTemperature = weatherDictionary["temperatureMin"] as! Int
        self.precipProbability = Int((weatherDictionary["precipProbability"] as! Double) * 100)
        self.humidity = Int(weatherDictionary["humidity"] as! Double * 100)
        self.summary = weatherDictionary["summary"] as! String
        let iconName = weatherDictionary["icon"] as! String
        self.icon = UIImage(named: "\(iconName).png")!
        self.day = dayStringFromTime(weatherDictionary["time"] as! Double, timeZone: timezone)

    }
    
    func dayStringFromTime(unixTime: Double, timeZone: String) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        dateFormatter.dateFormat = "EEEE"
        dateFormatter.timeZone = NSTimeZone(name: timeZone)
        
        return dateFormatter.stringFromDate(date)
    }

}