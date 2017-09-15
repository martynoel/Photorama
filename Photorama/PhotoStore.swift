//
//  PhotoStore.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import Foundation

/// PhotosResult represents state of JSON data from server
/// Success: Photo array, Failure: Error

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

/// PhotoStore handles actual web service calls.
/// Fetches list of Flickr's "interesting photos" & downloads their respective data

class PhotoStore {
    
    // Create session and config properties common across all tasks
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // Gets interesting photos from server
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        
        // Create URL instance using static function on FlickrAPI struct
        let url = FlickrAPI.interestingPhotosURL
        
        // Connect to API & asks for list of interesting photos using URL instance
        let request = URLRequest(url: url)
        
        // Transfer request to server
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            // Uses its own processPhotosRequest(data: error:) to parse data
            let result = self.processPhotosRequest(data: data, error: error)
            
            completion(result)
        }
        task.resume()
    }
    
    // Helper function for fetchInterestingPhotos()
    // Uses photos(fromJSON:) to process photos
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        return FlickrAPI.photos(fromJSON: jsonData)
    }
}
