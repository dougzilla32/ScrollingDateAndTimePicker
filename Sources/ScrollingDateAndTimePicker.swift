//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


public protocol ScrollingDateAndTimePickerDelegate: class {
    func datepicker(_ datepicker: ScrollingDateAndTimePicker, didSelectDate date: Date)

    func timepicker(_ timepicker: ScrollingDateAndTimePicker, didSelectTime time: Date)
}


open class ScrollingDateAndTimePicker: LoadableFromXibView {

    @IBOutlet weak var selectorBackground: UIView!
    @IBOutlet weak var selectorBackgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var selectorBar: UIView!
    @IBOutlet weak var selectorBarWidth: NSLayoutConstraint!
    
    public var continuousSelection: Bool = true {
        didSet {
            if continuousSelection {
                selectorBackground.isHidden = false
            }
            else {
                selectorBackground.isHidden = true
            }
        }
    }
    
    public var dates: [Date]? {
        get { return datePicker.dates }
        set { datePicker.dates = newValue }
    }
    
    public var times: [Date]? {
        get { return timePicker.dates }
        set { timePicker.dates = newValue }
    }
    
    public var selectedDate: Date? {
        get { return timePicker.selectedDate }
        set {
            datePicker.selectedDate = newValue
            timePicker.selectedDate = newValue
        }
    }
    
    public func scrollToSelectedDate(animated: Bool) {
        datePicker.scrollToSelectedDate(animated: animated)
        timePicker.scrollToSelectedDate(animated: animated)
    }
    
    public var dateConfiguration = DayConfiguration() {
        didSet { datePicker.configuration = dateConfiguration }
    }
    
    public var timeConfiguration = TimeConfiguration() {
        didSet { timePicker.configuration = timeConfiguration }
    }
    
    var dateCellConfiguration: ((_ cell: UICollectionViewCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet { datePicker.cellConfiguration = dateCellConfiguration }
    }
    
    var timeCellConfiguration: ((_ cell: UICollectionViewCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet { timePicker.cellConfiguration = timeCellConfiguration }
    }
    
    var bundle: Bundle? {
        let podBundle = Bundle(for: ScrollingDateAndTimePicker.self)
        let bundlePath = podBundle.path(forResource: String(describing: type(of: self)), ofType: "bundle")
        var bundle: Bundle? = nil
        
        if bundlePath != nil {
            bundle = Bundle(path: bundlePath!)
        }
        
        return bundle
    }

    @IBOutlet weak var datePicker: DatePicker! {
        didSet {
            let cellNib = UINib(nibName: DayCell.ClassName, bundle: bundle)
            datePicker.register(cellNib, forCellWithReuseIdentifier: DayCell.ClassName)
            datePicker.parent = self
            datePicker.dataSource = datePicker
            datePicker.delegate = datePicker
            datePicker.configuration = dateConfiguration
        }
    }

    @IBOutlet weak var timePicker: TimePicker! {
        didSet {
            let cellNib = UINib(nibName: TimeCell.ClassName, bundle: bundle)
            timePicker.register(cellNib, forCellWithReuseIdentifier: TimeCell.ClassName)
            timePicker.parent = self
            timePicker.dataSource = timePicker
            timePicker.delegate = timePicker
            timePicker.configuration = timeConfiguration
        }
    }
    
    public weak var delegate: ScrollingDateAndTimePickerDelegate? {
        didSet {
            datePicker.pickerDelegate = delegate
            timePicker.pickerDelegate = delegate
        }
    }

    open override func layoutSubviews() {
        let size = dateConfiguration.sizeCalculation.calculateItemSize(frame: self.frame)
        selectorBarWidth.constant = size.width
        selectorBackgroundWidth.constant = size.width

        super.layoutSubviews()
        datePicker.reloadData()
        timePicker.reloadData()
        
        DispatchQueue.main.async {
            self.datePicker.scrollToSelectedDate(animated: false)
            self.timePicker.scrollToSelectedDate(animated: false)
        }
    }
}
