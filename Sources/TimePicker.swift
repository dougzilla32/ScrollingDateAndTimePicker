//
//  TimePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public class TimePicker: UICollectionView, Picker {
    private static let MinuteGranularity = 30
    
    typealias CellType = TimeCell
    
    var props = PickerStoredProperties(configuration: TimeConfiguration())
    
    var timeInterval = TimePicker.MinuteGranularity * 60

    weak var timeDelegate: ScrollingDateAndTimePickerDelegate?
    
    // Derived from https://stackoverflow.com/a/42626860/5468406
    func round(date: Date) -> Date {
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
    
    func didSelect(date: Date) {
        timeDelegate?.timepicker(self, didSelectTime: date)
    }
}

// MARK: - UICollectionViewDataSource

extension TimePicker: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickerCollectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return pickerCollectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegate

extension TimePicker: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickerCollectionView(collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TimePicker: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return pickerCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
}
