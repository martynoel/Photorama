//
//  FlickrAPI.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import Foundation

/// Error represents errors from Flickr server

enum FlickrError: Error {
    case invalidJSONData
}

/// EndPoint specifies which endpoint to hit on Flickr server

enum EndPoint: String {
    case interestingPhotos = "flickr.interestingness.getList"
}

/// FlickrAPI knows & handles all Flickr-related info
/// Parses JSON into relevant model objects

struct FlickrAPI {
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "a6d819499131071f158fd740860a5a88"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
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
    
    // Helper method for PhotoStore
    // Converts large JSON dictionary into array of photo dictionaries
    // Uses photo(fromJSON:) to get properties of each individual photo
    // Puts those properties in Photo objects
    static func photos(fromJSON data: Data) -> PhotosResult {
        do {
            // If valid JSON, jsonObject references model object
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            
            // Pull out relevant JSON data, digging into layers of dictionary
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let photos = jsonDictionary["photos"] as? [String:Any],
                let photosArray = photos["photo"] as? [[String:Any]] else {
                    return .failure(FlickrError.invalidJSONData)
            }
                    
            var finalPhotos = [Photo]()
            
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON) {
                    finalPhotos.append(photo)
                }
            }
            
            // If we couldn't parse photos in photosArray
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                return .failure(FlickrError.invalidJSONData)
            }
            
            return .success(finalPhotos)
        } catch let error {
            // If not valid JSON, pass along error
            return .failure(error)
        }
    }
    
    // Helper method for photos(fromJSON:)
    // Gets properties for each individual photo from each photo in array
    private static func photo(fromJSON json: [String:Any]) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["dateTaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString) else {
                // Don't have enough info to construct Photo object
                return nil
        }
        
        return Photo(title: title, photoID: photoID, remoteURL: url, dateTaken: dateTaken)
    }
}
