//
//  TimePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

class TimePicker: Picker {
    private static let MinuteGranularity = 30
    
    override var timeInterval: Int {
        return TimePicker.MinuteGranularity * 60
    }

    // Derived from https://stackoverflow.com/a/42626860/5468406
    override func round(date: Date) -> Date {
        // Find current date and date components
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        
        // Round to nearest 'MinuteGranuity':
        let modMinute = minute % TimePicker.MinuteGranularity
        let roundedMinute = minute - modMinute
        
        var roundedDate = calendar.date(bySettingHour: hour, minute: roundedMinute, second: 0, of: date)!
        if modMinute >= TimePicker.MinuteGranularity / 2 {
            roundedDate = calendar.date(byAdding: .minute, value: TimePicker.MinuteGranularity, to: roundedDate)!
        }
        return roundedDate
    }
    
    override func didSelect(date: Date) {
        pickerDelegate?.timepicker(parent, didSelectTime: date)
    }
    
    override func dequeueReusableCell(_ collectionView: UICollectionView, for indexPath: IndexPath) -> PickerCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: TimeCell.ClassName, for: indexPath) as! TimeCell
    }
}
