//
//  ImageLoader.swift
//  dog-images-generator-ui
//
//  Created by Nikolay N. Dutskinov on 10.03.23.
//

import Foundation
import UIKit
import Combine

protocol ImageLoadable {
    func loadImage(from url: URL, completion: @escaping (Result<UIImage,Error>) -> Void)
}

public final class ImageLoader: ImageLoadable {
    
    public static let shared = ImageLoader()
    private let cache: ImageCacheType

    public init(cache: ImageCacheType = ImageCache()) {
        self.cache = cache
    }
    
    /// Uses standard URLSession with datatask
    public func loadImage(from url: URL, completion: @escaping (Result<UIImage,Error>) -> Void) {
        if let image = cache[url] {
            return completion(.success(image))
        }
        
        return URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                if let image = UIImage(data: data) {
                    self.cache[url] = image
                    completion(.success(image))
                } else {
                    completion(.failure(NSError()))
                }
            }
        }.resume()
    }
}
