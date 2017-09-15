//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import Foundation

/// EndPoint specifies which endpoint to hit on Flickr server
enum EndPoint: String {
    case interestingPhotos = "flickr.interestingness.getList"
}

/// FlickrAPI knows & handles all Flickr-related info
/// Parses JSON into relevant model objects
struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    // Base URL, "gets" value from private static function defined below
    static var interestingPhotosURL: URL {
        return flickrURL(endPoint: .interestingPhotos, parameters: ["extras": "url_h, date_taken"])
    }
    
    // Creates Flickr URL for specific endpoint
    private static func flickrURL(endPoint: EndPoint, parameters: [String:String]?) -> URL {
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": EndPoint.interestingPhotos.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
}
