//
//  SimilarImageService.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import Foundation
import UIKit
import CoreML
import Vision

class SimilarImageService {
    let modelName = "ImageSimilarity"
    
    typealias Distance = Double
    typealias CompletionHandler = ([Distance]?, Error?) -> ()
    
    enum ServiceError: Error {
        case invalidImage
        case invalidResults
    }
    
    func calculateSimilarities(image: UIImage, completion: @escaping CompletionHandler) {
        print("calculateSimilarities")
    }
    
    static func similarImageIndices(distances: [Distance]) -> [Int] {
        return distances
            .enumerated()
            .map { (index: $0, distance: $1) }
            .sorted(by: { $0.distance < $1.distance })
            .map { $0.index }
    }
    
    private class ResponseHandler {
        var completion: CompletionHandler?
        init(_ completion: @escaping CompletionHandler) {
            self.completion = completion
        }
        
        func expire() {
            completion = nil
        }
        
        func handler(request: VNRequest, error: Error?) {
            defer { expire() }
            guard error == nil else {
                completion?(nil, error)
                return
            }
            guard
                let results = request.results,
                let predictions = results as? [VNCoreMLFeatureValueObservation],
                let array = predictions.first?.featureValue.multiArrayValue
            else {
                completion?(nil, ServiceError.invalidResults)
                return
            }
            completion?(processArray(array), nil)
        }
        
        func processArray(_ array: MLMultiArray) -> [Double] {
            var distances: [Double] = []
            let count = array.count
            for i in 0..<count {
                distances.append(array[i].doubleValue)
            }
            return distances
        }
    }
}
