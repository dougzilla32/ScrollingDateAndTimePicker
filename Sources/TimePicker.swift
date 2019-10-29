//
//  TimePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

class TimePicker: Picker {
    var minuteGranularity = 60
    var showTimeRange = false
    
    override var infiniteScrollCount: Int {
        return DatePicker.InfiniteScrollCount * 24
    }
    
    override func infiniteScrollDate(at index: Int, anchorDate: Date) -> Date {
        return Calendar.current.date(byAdding: .hour, value: index, to: anchorDate)!
    }
    
    override func infiniteScrollIndex(of date: Date, anchorDate: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: anchorDate, to: date).hour!
    }
    
    // Derived from https://stackoverflow.com/a/42626860/5468406
    override func truncate(date: Date) -> Date {
        // Find current date and date components
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Truncate to 'MinuteGranuity':
        let modMinute = minute % self.minuteGranularity
        let truncatedMinute = minute - modMinute
        return calendar.date(bySettingHour: hour, minute: truncatedMinute, second: 0, of: date)!
    }
    
    override func didSelect(date: Date) {
        if let datePicker = parent?.datePicker, datePicker.selectedDate != datePicker.truncate(date: date) {
            datePicker.selectedDate = date
            datePicker.scrollToSelectedDate(animated: !datePicker.isScrolling)
        }
        pickerDelegate?.timepicker(parent, didSelectTime: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCell.ClassName, for: indexPath) as! TimeCell
        cell.showTimeRange = self.showTimeRange
        return cell
    }
    
    override func configureCell(_ cell: PickerCell, date: Date, isWeekend: Bool, isSelected: Bool) {
        cellConfigurer?(cell as! TimeCell, date, isWeekend, isSelected)
    }

    var cellConfigurer: ((_ cell: TimeCell, _ date: Date, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet {
            reloadData()
        }
    }
    
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.datePicker.scrollToSelectedDate(animated: false)
    }

    var day: Date? {
        didSet {
            if let day = self.day, day != oldValue, let selectedDate = self.selectedDate {
                let hour = Calendar.current.component(.hour, from: selectedDate)
                self.selectedDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: day)!
            }
        }
    }
}
