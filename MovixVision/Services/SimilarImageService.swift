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
    let similarImageService = try! image_encoder.init(configuration: MLModelConfiguration())
    
    typealias Distance = Double
    typealias CompletionHandler = ([Distance]?, Error?) -> ()
    
    enum ServiceError: Error {
        case invalidImage
        case invalidResults
    }
    
    func calculateSimilarities(image: UIImage, completion: @escaping CompletionHandler) {
        DispatchQueue.global(qos: .userInitiated).async {
            let orientation   = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue))!
            guard let ciImage = CIImage(image: image) else {
                completion(nil, ServiceError.invalidImage)
                return
            }
            
            let model = try! VNCoreMLModel(for: self.similarImageService.model)
            let responseHandler = ResponseHandler(completion)
            let request = VNCoreMLRequest(model: model, completionHandler: responseHandler.handler)
            request.imageCropAndScaleOption = .centerCrop
            
            do {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
                try handler.perform([request])
            } catch {
                responseHandler.expire()
                completion(nil, error)
            }
        }
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
                let array1 = predictions[0].featureValue.multiArrayValue,
                let array2 = predictions[1].featureValue.multiArrayValue
            else {
                completion?(nil, ServiceError.invalidResults)
                return
            }
            completion?(processArray(array1, array2), nil)
        }
        
        func processArray(_ array1: MLMultiArray, _ array2: MLMultiArray) -> [Double] {
            //            var distances: [Double] = []
            //            let count = array.count
            //            for i in 0..<count {
            //                distances.append(array[i].doubleValue)
            //            }
            //            return distances
            return [0, 0]
        }
    }
}
