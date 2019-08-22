//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


public protocol ScrollingDateAndTimePickerDelegate: class {
    func datepicker(_ datepicker: DatePicker, didSelectDate date: Date)

    func timepicker(_ timepicker: TimePicker, didSelectTime time: Date)
}


open class ScrollingDateAndTimePicker: LoadableFromXibView {
    
    var bundle: Bundle? {
        let podBundle = Bundle(for: ScrollingDateAndTimePicker.self)
        let bundlePath = podBundle.path(forResource: String(describing: type(of: self)), ofType: "bundle")
        var bundle: Bundle? = nil
        
        if bundlePath != nil {
            bundle = Bundle(path: bundlePath!)
        }
        
        return bundle
    }

    @IBOutlet public weak var datePicker: DatePicker! {
        didSet {
            let cellNib = UINib(nibName: DayCell.ClassName, bundle: bundle)
            datePicker.register(cellNib, forCellWithReuseIdentifier: DayCell.ClassName)
            datePicker.dataSource = datePicker
            datePicker.delegate = datePicker
        }
    }

    @IBOutlet public weak var timePicker: TimePicker! {
        didSet {
            let cellNib = UINib(nibName: TimeCell.ClassName, bundle: bundle)
            timePicker.register(cellNib, forCellWithReuseIdentifier: TimeCell.ClassName)
            timePicker.dataSource = timePicker
            timePicker.delegate = timePicker
        }
    }
    
    public weak var delegate: ScrollingDateAndTimePickerDelegate? {
        didSet {
            datePicker.dateDelegate = delegate
            timePicker.timeDelegate = delegate
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        datePicker.reloadData()
        timePicker.reloadData()
        
        DispatchQueue.main.async {
            self.datePicker.scrollToSelectedDate(animated: false)
            self.timePicker.scrollToSelectedDate(animated: false)
        }
    }
}
