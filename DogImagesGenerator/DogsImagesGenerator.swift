//
//  DogsImagesGenerator.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import Foundation
import UIKit

protocol DogGeneratorInput {
    var output: DogGeneratorOutput? { get set }
    func getImage()
    func getImages(number: Int)
    func getNextImage()
    func getPreviousImage()
    
    // didTapNext() -- increases the current index position of the array of images
    // check whether the current position is in limits (position>0 && position < limit of the array)
    // return possibly with output an indication that the button has to be stopped
}

protocol DogGeneratorOutput: AnyObject {
//    func didFetchImages(images: [UIImage])
    func didGetNextImage(image: UIImage?)
    func didGetPreviousImage(image: UIImage?)
}

public final class DogsImagesGenerator {

    private var imageURLs: [String] = []
    private let dogService: DogsImagesService
    private let imageLoader = ImageLoader()
    weak var output: DogGeneratorOutput?
    
    init(dogService: DogsImagesService = APIManager()) {
        self.dogService = dogService
    }
    
}

extension DogsImagesGenerator: DogGeneratorInput {
    func getImage() {
        // Gets random image
    }
    
    func getImages(number: Int) {
        // fetches random images
        dogService.fetchDogImages(number: number) { [weak self] result in
            switch result {
            case .success(let images):
                print(images.message)
//                self?.output?.didFetchImages(images: success.message)
                
                self?.imageURLs = images.message
                let url = URL(string: images.message.first!)!
                // Standard
                self?.imageLoader.loadImage(from: url, completion: { result in
                    switch result {
                    case .success(let success):
                        self?.output?.didGetNextImage(image: success)
                    case .failure(let failure):
                        print(failure)
                    }
                })
                self?.imageURLs = images.message
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
    }
    
    func getNextImage() {
        // gets next image from current
        //Clicking on the “Next” button should randomly get an image of a dog from the library.
    }
    
    func getPreviousImage() {
        // gets previous image from current
        //Clicking on “Previous” should get the previous image
    }
}
