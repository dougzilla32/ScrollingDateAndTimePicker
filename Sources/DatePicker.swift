//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public class DatePicker: UICollectionView, Picker {
    typealias ConfigurationType = DayConfiguration
    typealias CellType = DayCell

    var props = PickerStoredProperties(configuration: DayConfiguration())
    
    var timeInterval = 86400
    
    weak var dateDelegate: ScrollingDateAndTimePickerDelegate?
    
    func round(date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }

    func didSelect(date: Date) {
        dateDelegate?.datepicker(self, didSelectDate: date)
    }
}

// MARK: - UICollectionViewDataSource

extension DatePicker: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickerCollectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return pickerCollectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegate

extension DatePicker: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pickerCollectionView(collectionView, didSelectItemAt: indexPath)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DatePicker: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return pickerCollectionView(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
    }
    
}
