//
//  MovieService.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import Foundation
import UIKit
import CoreML

class MovieService: SimilarImageService {
    
    enum LoadError: Error {
        case couldNotUpdateFromAsset
    }
    
    typealias MoviesCompletionHandler = ([Int]?, Error?) -> ()
    
    var moviesDB = MoviesDB()
    
    func findMovies(similarTo image: UIImage, completion: @escaping MoviesCompletionHandler) {
        super.calculateSimilarities(image: image) { distances, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(distances.flatMap(SimilarImageService.similarImageIndices), nil)
        }
    }
    
    func movie(at index: Int) -> Movie? {
        return moviesDB[index]
    }
}
