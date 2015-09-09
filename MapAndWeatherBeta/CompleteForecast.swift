//
//  CompleteForecast.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/28/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation

struct CompleteForecast {
    var currentWeather: CurrentWeather?
    var weeklyWeather: [DailyWeather] = []
    
    let timeZoneService = TimeZoneService()
    var timezone: String = ""
    
    init(weatherDictionary: [String: AnyObject]?, userLatitude: String, userLongitude: String, timezone: String) {
        if let currentWeatherDicitionary = weatherDictionary?["currently"] as? [String: AnyObject] {
            currentWeather = CurrentWeather(weatherDictionary: currentWeatherDicitionary)
        }
        if let weeklyWeatherDictionary = weatherDictionary?["daily"]?["data"] as? [[String: AnyObject]] {
            for dailyWeather in weeklyWeatherDictionary {
                let dailyWeatherForecast = DailyWeather(weatherDictionary: dailyWeather, timezone: timezone)
                self.weeklyWeather.append(dailyWeatherForecast)
            }
        }
    }

}