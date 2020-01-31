//
//  TimePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public enum MinuteGranularity: Int {
    case sixty = 60, thirty = 30, twenty = 20, fifteen = 15, twelve = 12, ten = 10, six = 6, five = 5, four = 4, three = 3, two = 2, one = 1
}

public class TimePicker: Picker {
    var minuteGranularity = MinuteGranularity.sixty
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
    
    override func truncate(date: Date) -> Date {
        var date = date
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date) % minuteGranularity.rawValue
        date = calendar.date(byAdding: .minute, value: -minutes, to: date)!
        date = calendar.date(byAdding: .second, value: -calendar.component(.second, from: date), to: date)!
        date = calendar.date(byAdding: .nanosecond, value: -calendar.component(.nanosecond, from: date), to: date)!
        return date
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
    
    override func isCurrent(date: Date) -> Bool {
        return date.isCurrentDay && date.isCurrentHour
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
