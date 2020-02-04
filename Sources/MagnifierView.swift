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
    var touchPoint: CGPoint!
    
    // Pass-through for all events
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
    
    override func draw(_ rect: CGRect) {
        guard let magnification = self.magnification,
            let viewToMagnify = self.viewToMagnify,
            let touchPoint = self.touchPoint else {
                return
        }

        let ctx = UIGraphicsGetCurrentContext()!
        ctx.translateBy(x: self.frame.size.width * 0.5, y: self.frame.size.height * 0.5)
        ctx.scaleBy(x: magnification, y: magnification)
        ctx.translateBy(x: -touchPoint.x, y: -touchPoint.y)
        viewToMagnify.layer.render(in: ctx)
    }
}
