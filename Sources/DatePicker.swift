//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public class DatePicker: Picker {
    static let InfiniteScrollCount = 2000
    
    override var infiniteScrollCount: Int {
        return DatePicker.InfiniteScrollCount
    }
    
    override func infiniteScrollDate(at index: Int, anchorDate: Date) -> Date {
        return Calendar.current.date(byAdding: .day, value: index, to: anchorDate)!
    }
    
    override func infiniteScrollIndex(of date: Date, anchorDate: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: anchorDate, to: date).day!
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
    
    override func isCurrent(date: Date) -> Bool {
        return date.isCurrentDay
    }
    
    // Immediately cancel the timepicker scroll
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.timePicker.scrollToSelectedDate(animated: false)
    }
}
