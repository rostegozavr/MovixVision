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
    
    let modelFileName = "ImageSimilarity.mlmodel"
    let metadataFileName = "movies.json"
    let fileManager = FileManager.default
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    typealias MoviesCompletionHandler = ([Int]?, Error?) -> ()
    
    var moviesDB = MoviesDB()
    
    func loadModels() {
        DispatchQueue.global(qos: .userInteractive).async {
            if let modelPath = self.find(fileNamed: self.modelFileName),
               let modelURL = try? MLModel.compileModel(at: modelPath),
               let model = try? MLModel(contentsOf: modelURL),
               let metadataPath = self.find(fileNamed: self.metadataFileName),
               let moviesDB = MoviesDB(metadataPath: metadataPath.path)
            {
                DispatchQueue.main.async {
                    self.moviesDB = moviesDB
                    print(model)
                    //self.similarImageService.model = model
                }
            }
        }
    }
    
    func findMovies(similarTo image: UIImage, completion: @escaping MoviesCompletionHandler) {
        super.calculateSimilarities(image: image) { distances, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            completion(distances.flatMap(SimilarImageService.similarImageIndices), nil)
        }
    }
    
    func find(fileNamed name: String) -> URL? {
        guard let paths = fileManager.enumerator(atPath: documentsURL.path) else {
            return nil
        }
        for case let path as String in paths {
            let url = URL(fileURLWithPath: path)
            if url.lastPathComponent == name {
                return documentsURL.appendingPathComponent(path)
            }
        }
        return nil
    }
    
    func movie(at index: Int) -> Movie? {
        return moviesDB[index]
    }
}
