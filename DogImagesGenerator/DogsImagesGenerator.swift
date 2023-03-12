//
//  DogsImagesGenerator.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import Foundation
import UIKit

protocol DogGeneratorInput {
//    var output: DogGeneratorOutput? { get set }
    func getImage(completion: @escaping (Result<UIImage, Error>) -> Void)
    func getImages(number: Int, completion: @escaping (Result<[String], Error>) -> Void)
    func getNextImage(completion: @escaping (Result<UIImage, Error>) -> Void)
    func getPreviousImage(completion: @escaping (Result<UIImage, Error>) -> Void)
    // didTapNext() -- increases the current index position of the array of images
    // check whether the current position is in limits (position>0 && position < limit of the array)
    // return possibly with output an indication that the button has to be stopped
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

extension DogsImagesGenerator: DogGeneratorInput {
    
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
        }
        
    }
}

extension Collection where Indices.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
