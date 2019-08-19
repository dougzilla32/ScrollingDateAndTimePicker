//
//  DatePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import Foundation
import UIKit

public class DatePicker: UICollectionView {
    public var dates = [Date]() {
        didSet {
            reloadData()
        }
    }

    public var selectedDate: Date? {
        didSet {
            reloadData()
        }
    }

    public weak var dateDelegate: ScrollingDateAndTimePickerDelegate?

    public var cellConfiguration: ((_ cell: DayCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet {
            reloadData()
        }
    }

    public func scrollToSelectedDate(animated: Bool) {
        guard let index = dates.firstIndex(where: isSelected) else {
            return
        }
        
        scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        reloadData()
    }

    public var configuration = DayConfiguration() {
        didSet {
            reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension DatePicker: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DayCell.ClassName, for: indexPath) as! DayCell
        
        let date = dates[indexPath.row]
        let isWeekendDate = isWeekday(date: date)
        let isSelectedDate = isSelected(date: date)

        cell.setup(date: date, style: configuration.calculateDayStyle(isWeekend: isWeekendDate, isSelected: isSelectedDate))
        
        if let configuration = cellConfiguration {
            configuration(cell, isWeekendDate, isSelectedDate)
        }
        
        return cell
    }
    
    private func isWeekday(date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    private func isSelected(date: Date) -> Bool {
        guard let selectedDate = selectedDate else {
            return false
        }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
}

// MARK: - UICollectionViewDelegate

extension DatePicker: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let date = dates[indexPath.row]
        selectedDate = date
        dateDelegate?.datepicker(self, didSelectDate: date)
        scrollToSelectedDate(animated: true)
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension DatePicker: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat
        switch configuration.daySizeCalculation {
        case .constantWidth(let width):
            itemWidth = width
            break
        case .numberOfVisibleItems(let count):
            itemWidth = collectionView.frame.width / CGFloat(count)
            break
        }
        return CGSize(width: itemWidth, height: collectionView.frame.height)
    }
    
}
