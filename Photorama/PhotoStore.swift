//
//  PhotoStore.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit

/// ImageResult represents result of downloading image

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

/// PhotoError represents photo errors

enum PhotoError: Error {
    case imageCreationError
}

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
    
    // Downloads image data
    func fetchImage(for photo: Photo, completion: @escaping (ImageResult) -> Void) {
        let photoURL = photo.remoteURL
        let request = URLRequest(url: photoURL)
        
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
            
            let result = self.processImageRequest(data: data, error: error)
            
            completion(result)
        }
        task.resume()
    }
    
    // Processes data from web service request into image data, if possible
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        guard
            let imageData = data,
            let image = UIImage(data: imageData) else {
                
                // Couldn't create an image
                if data == nil {
                    return .failure(error!)
                } else {
                    return .failure(PhotoError.imageCreationError)
                }
        }
        return .success(image)
    }
}
