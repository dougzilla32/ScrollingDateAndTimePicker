//
//  MagnifierView.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 1/31/20.
//  From: https://coffeeshopped.com/2010/03/a-simpler-magnifying-glass-loupe-view-for-the-iphone
//

import UIKit

class MagnifierView: UIView {
    var magnification: CGFloat?
    weak var viewToMagnify: UIView?
    weak var labelToMagnify: UIView?
    var drawCallback: ((CGRect) -> Void)?
    var touchPoint: CGPoint!
    
    // Pass-through for all events
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return (view?.isDescendant(of: self) ?? false) ? nil : view
    }
    
    override func draw(_ rect: CGRect) {
        if let drawCallback = self.drawCallback {
            drawCallback(rect)
            return
        }
        
        guard let magnification = self.magnification,
            let touchPoint = self.touchPoint else {
                return
        }

        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        ctx.scaleBy(x: magnification, y: magnification)
        ctx.translateBy(x: -touchPoint.x, y: -touchPoint.y)
        viewToMagnify?.layer.render(in: ctx)
        labelToMagnify?.layer.render(in: ctx)
    }
}
