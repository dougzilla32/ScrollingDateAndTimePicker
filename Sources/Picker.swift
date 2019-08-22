//
//  Picker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

protocol Picker: AnyObject {
    associatedtype CellType: PickerCell
    
    var props: PickerStoredProperties { get set }
    
    var timeInterval: Int { get }
    
    func round(date: Date) -> Date
    func didSelect(date: Date)
    func reloadItems(at: [IndexPath])
    func reloadData()
    func scrollToItem(at: IndexPath, at: UICollectionView.ScrollPosition, animated: Bool)
}

class PickerStoredProperties {
    var infiniteScrollAnchorDate: Date?
    var dates: [Date]? = [Date]()
    var selectedDate: Date?
    var prevSelectedIndex: Int?
    var cellConfiguration: ((_ cell: UICollectionViewCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)?
    var configuration: PickerConfiguration
    
    init(configuration: PickerConfiguration) {
        self.configuration = configuration
    }
}

extension Picker {
    var InfiniteScrollCount: Int { return 1500 }
    var InfiniteScrollAnchorIndex: Int { return InfiniteScrollCount / 3 }

    var infiniteScrollAnchorDate: Date? {
        get { return props.infiniteScrollAnchorDate }
        set { props.infiniteScrollAnchorDate = newValue }
    }

    // Nil means infinite scrolling around the current date and time
    var dates: [Date]? {
        get { return props.dates }
        
        set {
            props.dates = newValue
            if newValue == nil {
                infiniteScrollAnchorDate = round(date: Date())
            }
            else {
                infiniteScrollAnchorDate = nil
            }
            reloadData()
        }
    }

    func reloadItemsNoAnimation(at indexPaths: [IndexPath]) {
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        reloadItems(at: indexPaths)
        UIView.setAnimationsEnabled(animationsEnabled)
    }

    func date(at indexPath: IndexPath) -> Date {
        return dates?[indexPath.row]
            ?? infiniteScrollAnchorDate!.addingTimeInterval(
                TimeInterval((indexPath.row - InfiniteScrollAnchorIndex) * timeInterval))
    }

    var selectedDate: Date? {
        get { return props.selectedDate }
        
        set {
            props.selectedDate = newValue

            if let date = newValue {
                props.selectedDate = round(date: date)
            }
            var pathsToReload = [IndexPath]()
            if let index = prevSelectedIndex {
                pathsToReload.append(IndexPath(row: index, section: 0))
            }
            if let index = selectedIndex {
                pathsToReload.append(IndexPath(row: index, section: 0))
                prevSelectedIndex = index
            }
            reloadItemsNoAnimation(at: pathsToReload)
        }
    }

    var prevSelectedIndex: Int? {
        get { return props.prevSelectedIndex }
        set { props.prevSelectedIndex = newValue }
    }
    
    var selectedIndex: Int? {
        return dates?.firstIndex(where: isSelected) ?? infiniteScrollSelectedDateIndex
    }
    
    var cellConfiguration: ((_ cell: CellType, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        get { return props.cellConfiguration }
        set {
            // ToDo: messy!
            props.cellConfiguration = newValue as? ((UICollectionViewCell, Bool, Bool) -> Void)
            reloadData()
        }
    }
    
    func scrollToSelectedDate(animated: Bool) {
        guard let index = selectedIndex else {
            return
        }
        
        scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
//        reloadData()
    }

    private var infiniteScrollSelectedDateIndex: Int? {
        guard let date = selectedDate, let anchor = infiniteScrollAnchorDate else {
            return nil
        }
        let interval = date.timeIntervalSince(anchor)
        return InfiniteScrollAnchorIndex + Int(interval) / timeInterval
    }
    
    var configuration : PickerConfiguration {
        get { return props.configuration }
        set {
            props.configuration = newValue
            reloadData()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension Picker {
    func pickerCollectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates?.count ?? InfiniteScrollCount
    }

    func pickerCollectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.ClassName, for: indexPath) as! CellType
        
        let date = self.date(at: indexPath)
        let isWeekendDate = isWeekday(date: date)
        let isSelectedDate = isSelected(date: date)

        cell.setup(date: date, style: configuration.calculateStyle(isWeekend: isWeekendDate, isSelected: isSelectedDate))
        
        if let configuration = cellConfiguration {
            configuration(cell, isWeekendDate, isSelectedDate)
        }
        
        return cell
    }
    
    private func isWeekday(date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    private func isSelected(date: Date) -> Bool {
        return date == selectedDate
    }
    
}

// MARK: - UICollectionViewDelegate

extension Picker {
    public func pickerCollectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let date = self.date(at: indexPath)
        selectedDate = date
        didSelect(date: date)
        scrollToSelectedDate(animated: true)
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

 extension Picker {

    public func pickerCollectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 50.0, height: 50.0)
        let itemWidth: CGFloat
        switch configuration.sizeCalculation {
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
