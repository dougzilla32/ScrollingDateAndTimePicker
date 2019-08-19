//
//  TimePicker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import Foundation
import UIKit

public class TimePicker: UICollectionView {
    public var times = [Date]() {
        didSet {
            reloadData()
        }
    }
    
    public var selectedTime: Date? {
        didSet {
            reloadData()
        }
    }

    public weak var timeDelegate: ScrollingDateAndTimePickerDelegate?
    
    public var cellConfiguration: ((_ cell: TimeCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet {
            reloadData()
        }
    }

    public func scrollToSelectedTime(animated: Bool) {
        guard let index = times.firstIndex(where: isSelected) else {
            return
        }
        
        scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        reloadData()
    }

    public var configuration = TimeConfiguration() {
        didSet {
            reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension TimePicker: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TimeCell.ClassName, for: indexPath) as! TimeCell
        
        let time = times[indexPath.row]
        let isWeekendTime = isWeekend(time: time)
        let isSelectedTime = isSelected(time: time)
        
        cell.setup(time: time, style: configuration.calculateTimeStyle(isWeekend: isWeekendTime, isSelected: isSelectedTime))
        
        if let configuration = cellConfiguration {
            configuration(cell, isWeekendTime, isSelectedTime)
        }
        
        return cell
    }
    
    private func isWeekend(time: Date) -> Bool {
        return Calendar.current.isDateInWeekend(time)
    }
    
    private func isSelected(time: Date) -> Bool {
        guard let selectedTime = selectedTime else {
            return false
        }
        return time == selectedTime
        // return Calendar.current.isDate(time, inSameDayAs: selectedTime)
    }
    
}


// MARK: - UICollectionViewDelegate

extension TimePicker: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let time = times[indexPath.row]
        selectedTime = time
        timeDelegate?.timepicker(self, didSelectTime: time)
        scrollToSelectedTime(animated: true)
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension TimePicker: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth: CGFloat
        switch configuration.timeSizeCalculation {
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
