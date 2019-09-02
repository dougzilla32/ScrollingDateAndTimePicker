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
        return DatePicker.InfiniteScrollCount * (24 * 60 / self.minuteGranularity)
    }
    
    override var timeInterval: Int {
        return self.minuteGranularity * 60
    }

    // Derived from https://stackoverflow.com/a/42626860/5468406
    override func round(date: Date) -> Date {
        // Find current date and date components
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Round to nearest 'MinuteGranuity':
        let modMinute = minute % self.minuteGranularity
        let roundedMinute = minute - modMinute
        
        var roundedDate = calendar.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: date)!
        if modMinute >= self.minuteGranularity / 2 {
            roundedDate = calendar.date(byAdding: .minute, value: self.minuteGranularity, to: roundedDate)!
        }
        return roundedDate
    }
    
    override func didSelect(date: Date) {
        if let datePicker = parent?.datePicker, datePicker.selectedDate != datePicker.round(date: date) {
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

    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.datePicker.scrollToSelectedDate(animated: false)
    }

    var day: Date? {
        didSet {
            if let day = self.day,
                day != oldValue,
                let time = self.selectedDate {
                let timeRoundedToDay = Calendar.current.startOfDay(for: time)
                self.selectedDate = time.addingTimeInterval(day.timeIntervalSince(timeRoundedToDay))
            }
        }
    }
}
