//
//  Samples.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

class Samples: NSObject, UIScrollViewDelegate {
    static let ScrollViewTag = 1
    static let PageControlTag = 2
    
    let sampleNames = [
        "фраза1",
        "фраза2",
        "фраза3",
        "фраза4",
    ]

    let samplesView: UIView
    let scrollView: UIScrollView
    let pageControl: UIPageControl
    
    var currentPage: Int {
        let pageWidth = scrollView.contentSize.width / CGFloat(sampleNames.count)
        return Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
    }
    
    init?(samplesView: UIView) {
        guard
            let scrollView = samplesView.viewWithTag(Samples.ScrollViewTag) as? UIScrollView,
            let pageControl = samplesView.viewWithTag(Samples.PageControlTag) as? UIPageControl
        else {
            return nil
        }
        
        self.samplesView = samplesView
        self.scrollView = scrollView
        self.pageControl = pageControl
        super.init()
        buildScrollView()
        pageControl.numberOfPages = sampleNames.count
        scrollView.delegate = self
    }
    
    func buildScrollView() {
        var constraints: [NSLayoutConstraint] = []
        
        var lastLabel: UILabel?
        sampleNames.forEach { text in
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.contentMode = .scaleAspectFit
            label.backgroundColor = .white
            label.textColor = .black
            label.clipsToBounds = true
            scrollView.addSubview(label)
            
            let leftConstraint: NSLayoutConstraint
            if let last = lastLabel {
                leftConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: last, attribute: .trailing, multiplier: 1, constant: 0)
            } else {
                leftConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1, constant: 0)
            }
            let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: samplesView, attribute: .width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: samplesView, attribute: .height, multiplier: 1, constant: 0)
            constraints += [leftConstraint, widthConstraint, heightConstraint]
            
            lastLabel = label
        }
        if let last = lastLabel {
            let trailingConstraint = NSLayoutConstraint(item: last, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1, constant: 0)
            constraints.append(trailingConstraint)
        }
        NSLayoutConstraint.activate(constraints)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = currentPage
    }
    
    func currentSample() -> String? {
        let page = currentPage
        guard page >= 0 && page < sampleNames.count else {
            return nil
        }
        return sampleNames[page]
    }
}
