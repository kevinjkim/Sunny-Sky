//
//  AutocompleteService.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 8/11/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation

class AutocompleteService {
    
    let googleAPIKey = ""  //Enter Google Autocomplete API Key Here//
    let baseURL = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json")
    
    typealias predictionArray = ([String]?) -> Void
    
    func getPredicitonsForText(text: String, completion: predictionArray){
        let url: NSURL? = NSURL(string: "?input=\(text)&types=(cities)&key=\(googleAPIKey)", relativeToURL: baseURL)
        if let validURL = url {
            let stringURL = url?.absoluteString
            print(stringURL)
            let networkOperation = NetworkOperation(url: validURL)
            networkOperation.downloadJSONFromURLAsDictionary({ (let results) -> Void in
                if results != nil {
                    let status = results?["status"] as! String
                    if status == "OK" {
                        if let validPredictions = results?["predictions"] as? NSArray {
                            var predicitons: [String] = []
                            for location in validPredictions{
                                let place = location as! NSDictionary
                                predicitons.append(place["description"] as! String)
                            }
                            completion(predicitons)
                        } else {
                            print("No predictions")
                            completion(nil)
                        }
                    } else {
                        let error = results?["status"]
                        print("\(error)")
                        completion(["STATUS ERROR"])
                    }
                } else {
                    print("No results - network failure")
                    completion(nil)
                }
            })
        } else {
            print("Not a valid search URL")
            completion(nil)
        }
    }
}