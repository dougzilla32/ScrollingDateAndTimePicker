//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


public protocol ScrollingDateAndTimePickerDelegate: AnyObject {
    func datepicker(_ datepicker: ScrollingDateAndTimePicker, didSelectDate date: Date)

    func timepicker(_ timepicker: ScrollingDateAndTimePicker, didSelectTime time: Date)
}


open class ScrollingDateAndTimePicker: LoadableFromXibView {
    @IBOutlet weak var selectorBackground: UIView!
    @IBOutlet weak var selectorBackgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var topMagnifier: MagnifierView!
    @IBOutlet weak var topMagnifierWidth: NSLayoutConstraint!
    @IBOutlet weak var bottomMagnifier: MagnifierView!
    @IBOutlet weak var bottomMagnifierWidth: NSLayoutConstraint!
    @IBOutlet public weak var selectorBar: UIView!
    @IBOutlet weak var selectorBarWidth: NSLayoutConstraint!
    @IBOutlet public weak var selectorBarHeight: NSLayoutConstraint!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    
    public var continuousSelection: Bool = true {
        didSet {
            updateViewerVisibility()
            updateMagnifiers()
        }
    }
    
    public var isHapticFeedbackEnabled = false

    public var isHighlightingEnabled = false {
        didSet {
            if isHighlightingEnabled {
                updateViewerVisibility()
                updateMagnifiers()
            }
        }
    }
    
    public var magnification: CGFloat? {
        didSet {
            topMagnifier.magnification = magnification
            bottomMagnifier.magnification = magnification
            updateViewerVisibility()
            updateMagnifiers()
        }
    }
    
    private func updateViewerVisibility() {
        selectorBackground.isHidden = !continuousSelection || (magnification != nil) || isHighlightingEnabled
        topMagnifier.isHidden = !continuousSelection || (magnification == nil) && !isHighlightingEnabled
        bottomMagnifier.isHidden = !continuousSelection || (magnification == nil) && !isHighlightingEnabled
    }
    
    private func updateMagnifiers() {
        guard magnification != nil || isHighlightingEnabled else { return }
        
        // Wait until picker layer is updated before updating the magnifier layer -- couldn't figure out
        // a better way to do this.
        if magnification == nil && isHighlightingEnabled {
            self.timePicker.updateMagnifier()
            self.datePicker.updateMagnifier()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            self.timePicker.updateMagnifier()
            self.datePicker.updateMagnifier()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.timePicker.updateMagnifier()
                self.datePicker.updateMagnifier()
            }
        }
    }
    
    func didSelect(date: Date?) {
        guard let date = date else { return }
        
        do {
            let style = dateConfiguration.calculateStyle(
                isWeekend: Calendar.current.isDateInWeekend(date),
                isSelected: true,
                isHighlighted: true,
                isCurrent: date.isCurrentDay) as! DayStyleConfiguration
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM"
            monthLabel.text = formatter.string(from: date).uppercased()
            monthLabel.font = style.monthTextFont ?? monthLabel.font
            monthLabel.textColor = style.monthTextColor ?? monthLabel.textColor
        }

        do {
            let style = timeConfiguration.calculateStyle(
                isWeekend: Calendar.current.isDateInWeekend(date),
                isSelected: true,
                isHighlighted: true,
                isCurrent: date.isCurrentDay) as! TimeStyleConfiguration
            
            let dateText = TimeCell.text(forDate: date, showTimeRange: showTimeRange)
            weekDayLabel.text = dateText.weekDay.uppercased()
            weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
            weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor
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
    
    public var showTimeRange = false
    
    public var minuteGranularity: MinuteGranularity {
        get { return timePicker.minuteGranularity }
        set { timePicker.minuteGranularity = newValue }
    }
    
    public var selectedDate: Date? {
        get { return timePicker.selectedDate }
        set {
            datePicker.selectedDate = newValue
            timePicker.selectedDate = newValue
            didSelect(date: newValue)
        }
    }
    
    public func scrollToSelectedDate(animated: Bool) {
        let dateScrolled = datePicker.scrollToSelectedDate(animated: animated, scrollStyle: .secondaryWithHaptic)
        timePicker.scrollToSelectedDate(animated: animated, scrollStyle: dateScrolled ? .secondaryNoHaptic : .secondaryWithHaptic)
    }
    
    public var dateConfiguration = DayConfiguration() {
        didSet {
            datePicker.configuration = dateConfiguration
            didSelect(date: selectedDate)
        }
    }
    
    public var timeConfiguration = TimeConfiguration() {
        didSet {
            timePicker.configuration = timeConfiguration
            didSelect(date: selectedDate)
        }
    }
    
    public var dateCellConfigurer: ((_ cell: DayCell, _ date: Date, _ isWeekend: Bool, _ isSelected: Bool, _ isHighlighted: Bool) -> Void)? {
        didSet {
            datePicker.cellConfigurer = dateCellConfigurer
            didSelect(date: selectedDate)
        }
    }
    
    public var timeCellConfigurer: ((_ cell: TimeCell, _ date: Date, _ isWeekend: Bool, _ isSelected: Bool, _ isHighlighted: Bool) -> Void)? {
        didSet {
            timePicker.cellConfigurer = timeCellConfigurer
            didSelect(date: selectedDate)
        }
    }
    
    // ToDo: for better efficiency, update the configurations without recreating the cells
    public func updateCellConfigurations() {
        datePicker.reloadData()
        timePicker.reloadData()
        updateMagnifiers()
    }
    
//    var bundle: Bundle? {
//        let podBundle = Bundle(for: ScrollingDateAndTimePicker.self)
//        let bundlePath = podBundle.path(forResource: String(describing: type(of: self)), ofType: "bundle")
//        var bundle: Bundle? = nil
//
//        if bundlePath != nil {
//            bundle = Bundle(path: bundlePath!)
//        }
//
//        return bundle
//    }

    @IBOutlet public weak var datePicker: DatePicker! {
        didSet {
            let cellNib = UINib(nibName: DayCell.ClassName, bundle: .module)
            datePicker.register(cellNib, forCellWithReuseIdentifier: DayCell.ClassName)
            datePicker.parent = self
            datePicker.dataSource = datePicker
            datePicker.delegate = datePicker
            datePicker.configuration = dateConfiguration
        }
    }

    @IBOutlet public weak var timePicker: TimePicker! {
        didSet {
            let cellNib = UINib(nibName: TimeCell.ClassName, bundle: .module)
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

    override func xibSetup() {
        super.xibSetup()
        
        topMagnifier.viewToMagnify = datePicker
        datePicker.magnifier = topMagnifier
        topMagnifier.isHidden = true
        
        bottomMagnifier.viewToMagnify = timePicker
        timePicker.magnifier = bottomMagnifier
        bottomMagnifier.isHidden = true
    }

    open override func layoutSubviews() {
        let itemSize = dateConfiguration.sizeCalculation.calculateItemSize(frame: self.frame)
        selectorBarWidth.constant = itemSize.width
        selectorBackgroundWidth.constant = itemSize.width
        topMagnifierWidth.constant = itemSize.width
        bottomMagnifierWidth.constant = itemSize.width

        super.layoutSubviews()
        datePicker.reloadData()
        timePicker.reloadData()
        
        DispatchQueue.main.async {
            self.datePicker.scrollToSelectedDate(animated: false, scrollStyle: .secondaryNoHaptic)
            self.timePicker.scrollToSelectedDate(animated: false, scrollStyle: .secondaryNoHaptic)
        }
    }
}
