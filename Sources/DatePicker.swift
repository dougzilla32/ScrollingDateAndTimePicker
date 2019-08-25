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
    
    override func round(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    override func didSelect(date: Date) {
        // Adjust timepicker according to new datepicker selection
        if let timePicker = parent?.timePicker {
            timePicker.day = date
            timePicker.scrollToSelectedDate(animated: false)
        }
        pickerDelegate?.datepicker(parent, didSelectDate: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.ClassName, for: indexPath) as! DayCell
    }

    // Immediately cancel the timepicker scroll
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.timePicker.scrollToSelectedDate(animated: false)
    }
}
