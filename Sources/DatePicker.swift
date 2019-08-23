//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

class DatePicker: Picker {
    private static let MinuteGranularity = 60 * 24
    
    override var timeInterval: Int {
        return DatePicker.MinuteGranularity * 60
    }
    
    override func round(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    override func didSelect(date: Date) {
        pickerDelegate?.datepicker(parent, didSelectDate: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.ClassName, for: indexPath) as! DayCell
    }
}
