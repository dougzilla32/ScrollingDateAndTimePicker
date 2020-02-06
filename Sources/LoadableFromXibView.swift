//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


open class LoadableFromXibView: UIView {

    @IBOutlet public weak var view: UIView!


    // MARK: - Inits

    override public init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }


    // MARK: - Setup

    func xibSetup() {
        view = LoadableFromXibView.xibView(bundleClass: ScrollingDateAndTimePicker.self, owner: self)
        addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": view!]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["view": view!]))
    }
    
    static func xibView(bundleClass: AnyClass, owner: Any) -> UIView? {
        return xib(bundleClass: bundleClass, viewClass: type(of: owner) as! AnyClass)?.instantiate(withOwner: owner, options: nil).first as? UIView
    }

    static func xibView(bundleClass: AnyClass, viewClass: AnyClass) -> UIView? {
        return xib(bundleClass: bundleClass, viewClass: viewClass)?.instantiate(withOwner: nil, options: nil).first as? UIView
    }
    
    private static func xib(bundleClass: AnyClass, viewClass: AnyClass) -> UINib? {
        let podBundle = Bundle(for: bundleClass)
        var bundle: Bundle?
        if let bundlePath = podBundle.path(forResource: String(describing: bundleClass), ofType: "bundle") {
            bundle = Bundle(path: bundlePath)
        }
        return UINib(nibName: String(describing: viewClass), bundle: bundle)
    }
}
