//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Mimi Chenyao on 9/14/17.
//  Copyright © 2017 Mimi Chenyao. All rights reserved.
//

import UIKit

/// Displays interesting Flickr photos in view

class PhotosViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Requests photos from server using photo store
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            
            switch photosResult {
            case let .success(photos):
                print("Successfully found \(photos.count) photos.")
                
                if let firstPhoto = photos.first {
                    self.updateImageView(for: firstPhoto)
                }
                
            case let .failure(error):
                print("Error fetching interesting photos: \(error)")
            }
        }
    }
    
    // Fetches image and displays it in image view
    func updateImageView(for photo: Photo) {
        store.fetchImage(for: photo) { (imageResult) -> Void in
            
            switch imageResult {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }
}
