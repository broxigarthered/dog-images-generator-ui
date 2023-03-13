//
//  DogsImagesGenerator.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import Foundation
import UIKit

protocol ImageGenerator {
    // Returns the first image if there is such and error if there was problem loading
    func getImage(completion: @escaping (Result<UIImage, Error>) -> Void)
    // Returns an array of images urls depending on the input count
    func getImages(number: Int, completion: @escaping (Result<[String], Error>) -> Void)
    // Returns an image, starting from the first one. Retruns an error if there is no next image or there was a problem with loading the image
    func getNextImage(completion: @escaping (Result<UIImage, Error>) -> Void)
    // Returns the previous image if there is such. Returns an error if there is none
    func getPreviousImage(completion: @escaping (Result<UIImage, Error>) -> Void)
}

public enum ImageLoadingError: Error {
    case outOfRange
}

public final class DogsImagesGenerator {

    private(set) var imageURLs: [String] = []
    private(set) var currentIndex: Int = 0
    private let dogService: DogsImagesService
    private let imageLoader: ImageLoadable
    
    init(dogService: DogsImagesService = APIManager(),
         imageLoader: ImageLoadable = ImageLoader()) {
        self.dogService = dogService
        self.imageLoader = imageLoader
    }
}

extension DogsImagesGenerator: ImageGenerator {
    
    func getImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let urlString = imageURLs[safe: currentIndex],
           let url = URL(string: urlString) {
            imageLoader.loadImage(from: url) { result in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            completion(.failure(ImageLoadingError.outOfRange))
        }
    }
    
    func getImages(number: Int, completion: @escaping (Result<[String], Error>) -> Void) {
        dogService.fetchDogImages(number: number) { [weak self] result in
            switch result {
            case .success(let images):
                print(images.message)
                self?.imageURLs = images.message
                completion(.success(images.message))
            case .failure(let failure):
                completion(.failure(failure))
            }
        }
    }
    
    func getNextImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        currentIndex += 1
        if let urlString = imageURLs[safe: currentIndex],
           let url = URL(string: urlString) {
            
            imageLoader.loadImage(from: url) { result in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            currentIndex -= 1
            completion(.failure(ImageLoadingError.outOfRange))
        }
    }
    
    func getPreviousImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        currentIndex -= 1
        if let urlString = imageURLs[safe: currentIndex],
           let url = URL(string: urlString) {
            
            imageLoader.loadImage(from: url) { result in
                switch result {
                case .success(let image):
                    completion(.success(image))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            currentIndex += 1
            completion(.failure(ImageLoadingError.outOfRange))
        }
        
    }
}

extension Collection where Indices.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
