//
//  TimeZoneService.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 8/13/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation

class TimeZoneService {
    
    let apiKey = "" //Enter Google Timezone API Key Here//
    let baseURL = NSURL(string: "https://maps.googleapis.com/maps/api/timezone/json")
    
    typealias timeZoneCompletion = (String?) -> Void
    
    func getTimeZoneForCoordinates(lat: String, long: String, completion: timeZoneCompletion) {
        let location = "location=\(lat),\(long)"
        let timestamp = "timestamp=1440046800"
        let url = NSURL(string: "?\(location)&\(timestamp)&key=\(apiKey)", relativeToURL: baseURL)
        print(url?.absoluteString)
        if let validURL = url {
            let networkOperation = NetworkOperation(url: validURL)
            networkOperation.downloadJSONFromURLAsDictionary { (let results) -> Void in
                let status = results?["status"] as? String
                if status == "OK" {
                    if let validTimeZone = results?["timeZoneId"] as? String {
                        completion(validTimeZone)
                    } else {
                        print("Not valid time zone")
                        completion(nil)
                    }
                } else {
                    print("Timestamp status not OK")
                    completion(nil)
                }
            }
        } else {
            print("Not valid timestamp URL")
            completion(nil)
        }
    }
}