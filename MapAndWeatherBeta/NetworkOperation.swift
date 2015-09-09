//
//  NetworkOperation.swift
//  MapAndWeatherBeta
//
//  Created by Kevin Kim on 7/25/15.
//  Copyright © 2015 Kevin Kim. All rights reserved.
//

import Foundation

class NetworkOperation {
    let url: NSURL
    lazy var configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    lazy var session: NSURLSession = NSURLSession(configuration: self.configuration)
    
    init(url: NSURL) {
        self.url = url
    }
    
    typealias JSONCompletion = ([String: AnyObject]?) -> Void
    typealias dictCompletion = (NSDictionary?) -> Void
    
    func downloadJSONFromURL(completion: JSONCompletion) {
        let request: NSURLRequest = NSURLRequest(URL: self.url)
        let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [String: AnyObject]
                    completion(jsonDictionary)
                } catch {
                    print("Not a valid JSON Dictionary")
                }
            } else {
                print("Could not establish network connection")
                completion(nil)
            }
        }
        
        dataTask.resume()
    }
    
    func downloadJSONFromURLAsDictionary(completion: dictCompletion) {
        let request: NSURLRequest = NSURLRequest(URL: self.url)
        let dataTask: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            if error == nil {
                do {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                    completion(jsonDictionary)
                } catch {
                    print("Not a valid JSON Dictionary")
                }
            } else {
                print("Could not establish network connection")
                completion(nil)
            }
        }
        
        dataTask.resume()
    }
}