//
//  APIManager.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import Foundation

struct DogImages: Decodable {
    let message: [String]
    let status: String
}

protocol DogsImagesService {
    func fetchDogImages(number: Int, completion: @escaping (Result<DogImages, Error>) -> Void)
}

class APIManager: DogsImagesService {
    func fetchDogImages(number: Int, completion: @escaping (Result<DogImages, Error>) -> Void) {
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random/\(number)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            if let dogImages = try? JSONDecoder().decode(DogImages.self, from: data) {
                completion(.success(dogImages))
            } else {
                completion(.failure(NSError()))
            }
        }.resume()
    }
}
