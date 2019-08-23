//
//  Picker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

// From https://stackoverflow.com/a/46354989/5468406
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}

class Picker: UICollectionView {
    
    // MARK: - subclasses must override these
    
    var timeInterval: Int { get { fatalError() } }
    func round(date: Date) -> Date { fatalError() }
    func didSelect(date: Date) { fatalError() }
    func dequeueReusableCell(_: UICollectionView, for: IndexPath) -> PickerCell { fatalError() }

    // MARK: - properties and methods
    
    weak var parent: ScrollingDateAndTimePicker!
    weak var pickerDelegate: ScrollingDateAndTimePickerDelegate!

    private var InfiniteScrollCount: Int { return 1500 }
    private var InfiniteScrollAnchorIndex: Int { return InfiniteScrollCount / 3 }

    private lazy var infiniteScrollAnchorDate: Date? = {
        return round(date: Date())
    }()

    private var centerItem: Int?
    private var itemWidth: CGFloat!

    var dates: [Date]? {
        didSet {
            if let n = dates {
                infiniteScrollAnchorDate = nil
                var dates = [Date]()
                for d in n {
                    dates.append(round(date: d))
                }
                self.dates = dates.uniqued()
            }
            else {
                infiniteScrollAnchorDate = round(date: Date())
            }
            reloadData()
        }
    }

    var selectedDate: Date? {
        didSet {
            if let date = self.selectedDate {
                self.selectedDate = round(date: date)
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
    
    var cellConfiguration: ((_ cell: UICollectionViewCell, _ isWeekend: Bool, _ isSelected: Bool) -> Void)? {
        didSet {
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

    var selectedIndex: Int? {
        return dates?.firstIndex(where: isSelected) ?? infiniteScrollSelectedDateIndex
    }
    
    private var prevSelectedIndex: Int?

    private var infiniteScrollSelectedDateIndex: Int? {
        guard let date = selectedDate, let anchor = infiniteScrollAnchorDate else {
            return nil
        }
        let interval = date.timeIntervalSince(anchor)
        return InfiniteScrollAnchorIndex + Int(interval) / timeInterval
    }
    
    var configuration: PickerConfiguration! {
        didSet {
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
}

// MARK: - UICollectionViewDataSource

extension Picker: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates?.count ?? InfiniteScrollCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellType.ClassName, for: indexPath) as! CellType
        let cell = dequeueReusableCell(collectionView, for: indexPath)

        let date = self.date(at: indexPath)
        let isWeekendDate = isWeekday(date: date)
        let isSelectedDate = isSelected(date: date)
        if isSelectedDate {
            prevSelectedIndex = indexPath.row
        }

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

extension Picker: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let date = self.date(at: indexPath)
        selectedDate = date
        didSelect(date: date)
        scrollToSelectedDate(animated: true)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemWidth = scrollView.frame.width / CGFloat(5)
        let midLocationX = scrollView.contentOffset.x + (scrollView.frame.width / 2.0)
        let item = Int(midLocationX / itemWidth)
//        print("scrollView.contentOffset \(scrollView.contentOffset)")
//        print("  itemWidth \(itemWidth)")
//        print("  midLocationX \(midLocationX)")
        if item != centerItem {
            // ToDo: select the center item
            centerItem = item
//            print("centerItem: \(item)")
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                                withVelocity velocity: CGPoint,
                                                targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // ToDo: overshoots slightly
        let itemWidth = scrollView.frame.width / CGFloat(5)
        let halfFrame = scrollView.frame.width / 2.0
        let midLocationX = targetContentOffset.pointee.x + halfFrame
        let itemOffset = velocity.x > 0 ? (itemWidth / 2.0) : -(itemWidth / 2.0)
        let item = Int((midLocationX + itemOffset) / itemWidth)
        
        targetContentOffset.pointee.x = CGFloat(item) * itemWidth + itemWidth / 2 - halfFrame
    }
}


// MARK: - UICollectionViewDelegateFlowLayout

extension Picker: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
