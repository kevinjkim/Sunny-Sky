//
//  CurrentWeather.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/26/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather{
    let temperature: Int
    let precipProbability: Int
    let humidity: Int
    let summary: String
    let icon: UIImage
    
    init(weatherDictionary: [String: AnyObject]) {
        self.temperature = weatherDictionary["temperature"] as! Int
        self.precipProbability = Int((weatherDictionary["precipProbability"] as! Double) * 100)
        self.humidity = Int(weatherDictionary["humidity"] as! Double * 100)
        self.summary = weatherDictionary["summary"] as! String
        let iconName = weatherDictionary["icon"] as! String
        self.icon = UIImage(named: "\(iconName).png")!
    }
}