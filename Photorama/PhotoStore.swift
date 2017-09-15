//
//  PhotoStore.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import Foundation

/// PhotoStore handles actual web service calls.
/// Fetches list of Flickr's "interesting photos" & downloads their respective data

class PhotoStore {
    
    // Create session and config properties common across all tasks
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // Gets interesting photos from server
    func fetchInterestingPhotos() {
        
        // Create URL instance using static function on FlickrAPI struct
        let url = FlickrAPI.interestingPhotosURL
        
        // Connect to API & asks for list of interesting photos using URL instance
        let request = URLRequest(url: url)
        
        // Transfer request to server
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if let jsonData = data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    print(jsonObject)
                } catch let error {
                    print("Error creating JSON object: \(error)")
                }
            } else if let requestError = error {
                print("Error fetching interesting photos: \(requestError)")
            } else {
                print("Unexpected error with the request")
            }
        }
        task.resume()
    }
}
