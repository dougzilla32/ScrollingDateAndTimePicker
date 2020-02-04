//
//  TAProgressLayer.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 2/3/20.
//  Ported from: https://stackoverflow.com/a/19024971/5468406
//

import UIKit

protocol TAProgressDelegate {
    func progressUpdated(_ progress: CGFloat, in: CGContext)
}

class TAProgressAnimationDelegate: NSObject, CAAnimationDelegate {
    weak var progressLayer: TAProgressLayer?

    init(progressLayer: TAProgressLayer) {
        self.progressLayer = progressLayer
    }
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard let progressLayer = self.progressLayer else { return }
        self.progressLayer = nil
        progressLayer.cancel()
    }
}

public class TAProgressLayer : CALayer {
    static let ProgressKey = "progress"
    private static let ProgressDelegateKey = "progressDelegate"

    // MARK: - Progress-related properties

    @NSManaged var progress: CGFloat
    var progressDelegate: TAProgressDelegate? = nil

    // MARK: - Initialization & Encoding

    // We must copy across our custom properties since Core Animation makes a copy
    // of the layer that it's animating.

    override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? TAProgressLayer {
            self.progress = other.progress
            self.progressDelegate = other.progressDelegate
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        progressDelegate = aDecoder.decodeObject(forKey: TAProgressLayer.ProgressDelegateKey) as? TAProgressDelegate
        progress = CGFloat(aDecoder.decodeFloat(forKey: TAProgressLayer.ProgressKey))
    }

    override public func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(Float(progress), forKey: TAProgressLayer.ProgressKey)
        aCoder.encode(progressDelegate as Any, forKey: TAProgressLayer.ProgressDelegateKey)
    }

    convenience init(layer: CALayer, progressDelegate: TAProgressDelegate?) {
        self.init(layer: layer)
        frame = CGRect(x: 0, y: -1, width: 1, height: 1)
        self.progress = 0.0
        self.progressDelegate = progressDelegate
        layer.addSublayer(self)
    }

    // MARK: - Progress Reporting

    // Override needsDisplayForKey so that we can define progress as being animatable.
    class override public func needsDisplay(forKey key: String) -> Bool {
        if (key == TAProgressLayer.ProgressKey) {
            return true
        } else {
            return super.needsDisplay(forKey: key)
        }
    }

    // Call our callback

    override public func draw(in ctx: CGContext) {
        if let del = self.progressDelegate {
            del.progressUpdated(progress, in: ctx)
        }
    }
    
    func cancel() {
        removeAnimation(forKey: TAProgressLayer.ProgressKey)
        removeFromSuperlayer()
    }
}
