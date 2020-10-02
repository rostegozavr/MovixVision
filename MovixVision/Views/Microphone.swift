//
//  Microphone.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

class Microphone: NSObject, UIScrollViewDelegate {
    static let LabelTag = 1

    let microphoneView: UIView
    let label: UILabel
    
    init?(microphoneView: UIView) {
        
        guard let label = microphoneView.viewWithTag(Microphone.LabelTag) as? UILabel else {
            return nil
        }
        
        self.microphoneView = microphoneView
        self.label = label
        
        super.init()
    }
    
    func currentText() -> String? {
        return label.text
    }
}
