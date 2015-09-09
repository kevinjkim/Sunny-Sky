//
//  ForecastService.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/26/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation

struct ForecastService {
    let forecastAPIKey: String
    let baseURL: NSURL
    
    init(apiKey: String) {
        self.forecastAPIKey = apiKey
        self.baseURL = NSURL(string: "https://api.forecast.io/forecast/\(apiKey)/")!
    }
    
    
    typealias weatherDictionary = (CompleteForecast?) -> Void
    
    func getCurrentWeatherForLocation(lat: String, long: String, timezone: String, completion: weatherDictionary) {
        let url = NSURL(string: "\(lat),\(long)", relativeToURL: baseURL)
        
        let networkOperation = NetworkOperation(url: url!)
        networkOperation.downloadJSONFromURL { (let jsonDictionary) -> Void in
            if jsonDictionary != nil {
                let forecast = CompleteForecast(weatherDictionary: jsonDictionary, userLatitude: lat, userLongitude: long, timezone: timezone)
                completion(forecast)
            } else {
                completion(nil)
            }
        }
    }
    

}