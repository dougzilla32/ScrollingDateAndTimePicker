//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

class DatePicker: Picker {
    static let InfiniteScrollCount = 2000
    private static let MinuteGranularity = 24 * 60
    
    override var infiniteScrollCount: Int {
        return DatePicker.InfiniteScrollCount
    }
    
    override var timeInterval: Int {
        return DatePicker.MinuteGranularity * 60
    }
    
    override func truncate(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    override func didSelect(date: Date) {
        var date = date
        // Adjust timepicker according to new datepicker selection
        if let timePicker = parent?.timePicker {
            timePicker.day = date
            timePicker.scrollToSelectedDate(animated: false)
            date = timePicker.selectedDate ?? date
        }
        pickerDelegate?.datepicker(parent, didSelectDate: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.ClassName, for: indexPath) as! DayCell
    }
    
    override func configureCell(_ cell: PickerCell, date: Date, isWeekend: Bool, isSelected: Bool) {
        cellConfigurer?(cell as! DayCell, date, isWeekend, isSelected)
    }

    var cellConfigurer: ((_ cell: DayCell, _ date: Date, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet {
            reloadData()
        }
    }
    
    // Immediately cancel the timepicker scroll
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.timePicker.scrollToSelectedDate(animated: false)
    }
}
