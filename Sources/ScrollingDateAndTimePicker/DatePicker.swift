//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public class DatePicker: Picker {
    override var xibClass: AnyClass {
        return DayCell.self
    }
    
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

    override func didSelect(date: Date, animated: Bool, scrollStyle: PickerScrollStyle) {
        var date = date
        // Adjust timepicker according to new datepicker selection
        if scrollStyle == .primary, let timePicker = parent?.timePicker {
            timePicker.day = date
            timePicker.scrollToSelectedDate(animated: false, scrollStyle: .secondaryNoHaptic)
            date = timePicker.selectedDate ?? date
        }
        parent.didSelect(date: date)
        pickerDelegate?.datepicker(parent, didSelectDate: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.ClassName, for: indexPath) as! DayCell
    }
    
    override func configureCell(_ cell: PickerCell, date: Date, isWeekend: Bool, isSelected: Bool, isHighlighted: Bool) {
        cellConfigurer?(cell as! DayCell, date, isWeekend, isSelected, isHighlighted)
    }

    var cellConfigurer: ((_ cell: DayCell, _ date: Date, _ isWeekend: Bool, _ isSelected: Bool, _ isHighlighted: Bool) -> Void)? {
        didSet {
            reloadData()
        }
    }
    
    override func isCurrent(date: Date) -> Bool {
        return date.isCurrentDay
    }
    
    override func numberOfImpacts(from: Date, to: Date) -> Int {
        let seconds = from.timeIntervalSince(to)
        return Int(abs(round(seconds / (3600 * 24))))
    }
    
    // Immediately cancel the timepicker scroll
    override public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        parent?.timePicker.scrollToSelectedDate(animated: false, scrollStyle: .primary)
    }
}
