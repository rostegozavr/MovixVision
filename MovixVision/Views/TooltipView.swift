//
//  TooltipView.swift
//  MovixVision
//
//  Created by rosteg on 01.10.2020.
//

import UIKit

@IBDesignable class TooltipView: UIView {
    
    @IBInspectable var arrowWidth: CGFloat = 36
    @IBInspectable var arrowHeight: CGFloat = 18
    @IBInspectable var borderRadius: CGFloat = 4
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTooltipShape()
    }
    
    func setTooltipShape() {
        let size = self.bounds.size
        
        func point(x: CGFloat, y: CGFloat) -> CGPoint {
            return CGPoint(x: x, y: size.height - y)
        }
        
        let path = CGMutablePath()
        path.move(to: point(x: borderRadius, y: arrowHeight))
        path.addLine(to: point(x: round(size.width / 2.0 - arrowWidth / 2.0), y: arrowHeight))
        path.addLine(to: point(x: round(size.width / 2.0), y: 0))
        path.addLine(to: point(x: round(size.width / 2.0 + arrowWidth / 2.0), y: arrowHeight))
        path.addArc(tangent1End: point(x: size.width, y: arrowHeight), tangent2End: point(x: size.width, y: size.height), radius: borderRadius)
        path.addArc(tangent1End: point(x: size.width, y: size.height) , tangent2End: point(x: round(size.width / 2.0 + arrowWidth / 2.0), y: size.height) , radius: borderRadius)
        path.addArc(tangent1End: point(x: 0, y: size.height), tangent2End: point(x: 0, y: arrowHeight), radius: borderRadius)
        path.addArc(tangent1End: point(x: 0, y :arrowHeight), tangent2End: point(x: size.width ,y: arrowHeight), radius: borderRadius)
        path.closeSubpath()
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        layer.mask = maskLayer
    }
}
