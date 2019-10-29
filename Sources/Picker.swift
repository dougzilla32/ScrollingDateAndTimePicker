//
//  Picker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

class Picker: UICollectionView {
    // MARK: - subclasses must override these
    
    var infiniteScrollCount: Int { fatalError() }
    func infiniteScrollDate(at index: Int, anchorDate: Date) -> Date { fatalError() }
    func infiniteScrollIndex(of date: Date, anchorDate: Date) -> Int { fatalError() }
    func truncate(date: Date) -> Date { fatalError() }
    func didSelect(date: Date) { fatalError() }
    func dequeueReusableCell(_: UICollectionView, for: IndexPath) -> PickerCell { fatalError() }
    func configureCell(_ cell: PickerCell, date: Date, isWeekend: Bool, isSelected: Bool) { fatalError() }

    // MARK: - properties and methods
    
    weak var parent: ScrollingDateAndTimePicker!
    weak var pickerDelegate: ScrollingDateAndTimePickerDelegate!

    var isScrolling = false
    var isScrollAnimatingFromUser = false
    private var infiniteScrollAnchorIndex: Int { return infiniteScrollCount / 3 }

    private lazy var infiniteScrollAnchorDate: Date? = {
        return truncate(date: Date())
    }()

    private var centerItem: Int?
    private var cachedFrameWidth: CGFloat!
    private var cachedItemWidth: CGFloat!
    private var scrollEndWorkItem: DispatchWorkItem?

    var dates: [Date]? {
        didSet {
            if let n = dates {
                infiniteScrollAnchorDate = nil
                var dates = [Date]()
                for d in n {
                    dates.append(truncate(date: d))
                }
                self.dates = dates.uniqued()
            }
            else {
                infiniteScrollAnchorDate = truncate(date: selectedDate ?? Date())
            }
            reloadData()
        }
    }

    var selectedDate: Date? {
        didSet {
            if let date = self.selectedDate {
                self.selectedDate = truncate(date: date)
            }
            guard self.selectedDate != oldValue else {
                return
            }
            
            // Only need to redraw the selected and deselected item for
            // manual selection (i.e. non-continuous selection)
            if !(parent?.continuousSelection ?? true) {
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
    }
    
    func reloadItemsNoAnimation(at indexPaths: [IndexPath]) {
        let animationsEnabled = UIView.areAnimationsEnabled
        UIView.setAnimationsEnabled(false)
        reloadItems(at: indexPaths)
        UIView.setAnimationsEnabled(animationsEnabled)
    }

    func date(at index: Int) -> Date {
        return dates?[index] ?? infiniteScrollDate(at: index - infiniteScrollAnchorIndex, anchorDate: infiniteScrollAnchorDate!)
    }
    
    func index(of date: Date) -> Int? {
        let index: Int?
        if let dates = dates {
            index = dates.firstIndex(of: date)
        }
        else {
            index = infiniteScrollAnchorIndex + infiniteScrollIndex(of: date, anchorDate: infiniteScrollAnchorDate!)

        }
        return index
    }

    var selectedIndex: Int? {
        return dates?.firstIndex(where: isSelected) ?? infiniteScrollSelectedDateIndex
    }
    
    private var prevSelectedIndex: Int?

    private var infiniteScrollSelectedDateIndex: Int? {
        guard let date = selectedDate else {
            return nil
        }
        return infiniteScrollAnchorIndex + infiniteScrollIndex(of: date, anchorDate: infiniteScrollAnchorDate!)
    }
    
    var configuration: PickerConfiguration! {
        didSet {
            reloadData()
        }
    }
    
    func scrollToSelectedDate(animated: Bool) {
        if let index = selectedIndex, index >= 0, index < self.numberOfItems(inSection: 0) {
            cancelScroll()
            scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
            cancelScroll()
        }
    }
    
    func scrollTo(_ date: Date, animated: Bool) {
        if let index = self.index(of: date), index >= 0, index < self.numberOfItems(inSection: 0) {
            cancelScroll()
            scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
            cancelScroll()
        }
    }
    
    private func cancelScroll() {
        // Ensure that 'scrollViewDidEndScrollingAnimation' is always called
        // From https://stackoverflow.com/a/1857162/5468406
        self.isScrolling = false
        self.isScrollAnimatingFromUser = false
        scrollEndWorkItem?.cancel()
        scrollEndWorkItem = nil
    }
    
    open override func layoutSubviews() {
        let itemSize: CGSize
        if let w = cachedItemWidth, frame.width == cachedFrameWidth {
            itemSize = CGSize(width: w, height: frame.height)
        }
        else {
            itemSize = configuration.sizeCalculation.calculateItemSize(frame: frame)
            cachedFrameWidth = frame.width
            cachedItemWidth = itemSize.width
        }
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        if itemSize != layout.itemSize {
            layout.itemSize = itemSize
        }

        super.layoutSubviews()
    }
}

// MARK: - UICollectionViewDataSource

extension Picker: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates?.count ?? infiniteScrollCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(collectionView, for: indexPath)

        let date = self.date(at: indexPath.item)
        let isWeekendDate = isWeekday(date: date)
        let isSelectedDate = isSelected(date: date)
        if isSelectedDate {
            prevSelectedIndex = indexPath.item
        }

        cell.setup(date: date, style: configuration.calculateStyle(isWeekend: isWeekendDate, isSelected: isSelectedDate))
        
        configureCell(cell, date: date, isWeekend: isWeekendDate, isSelected: isSelectedDate)
        
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
        
        let date = self.date(at: indexPath.item)
        selectedDate = date
        didSelect(date: date)
        scrollToSelectedDate(animated: true)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
        self.isScrollAnimatingFromUser = false
        centerItem = nil
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                          withVelocity velocity: CGPoint,
                                          targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.isScrolling = true
        self.isScrollAnimatingFromUser = true
        guard let itemWidth = cachedItemWidth, let frameWidth = cachedFrameWidth else {
            return
        }
        let halfFrame = frameWidth / 2.0
        let midLocationX = targetContentOffset.pointee.x + halfFrame
        let itemOffset: CGFloat
        if velocity.x > 0 {
            itemOffset = itemWidth / 2.0
        }
        else if velocity.x < 0 {
            itemOffset = -(itemWidth / 2.0)
        }
        else {
            itemOffset = 0.0
        }
        let item = Int((midLocationX + itemOffset) / itemWidth)
        
        targetContentOffset.pointee.x = CGFloat(item) * itemWidth + itemWidth / 2 - halfFrame
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isScrolling { return }

        // Ensure that 'scrollViewDidEndScrollingAnimation' is always called
        // From https://stackoverflow.com/a/1857162/5468406
        scrollEndWorkItem?.cancel()
        let workItem = DispatchWorkItem {
            self.scrollViewDidEndScrollingAnimation(scrollView)
        }
        scrollEndWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
        
        // Continuous selection
        guard parent?.continuousSelection ?? false, let itemWidth = cachedItemWidth, let frameWidth = cachedFrameWidth else {
            return
        }
        let midLocationX = scrollView.contentOffset.x + frameWidth / 2.0
        let item = Int(midLocationX / itemWidth)
        if item != centerItem {
            centerItem = item
            let date = self.date(at: item)
            if date != selectedDate {
                selectedDate = date
                didSelect(date: date)
            }
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if !isScrollAnimatingFromUser { return }
        
        cancelScroll()

        // Scroll to the 'centerItem'
        if let item = centerItem, item >= 0, item < numberOfItems(inSection: 0) {
            centerItem = nil
            self.scrollToItem(at: IndexPath(item: item, section: 0),
                              at: .centeredHorizontally,
                              animated: true)
        }
    }
}

// From https://stackoverflow.com/a/46354989/5468406
public extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter{ seen.insert($0).inserted }
    }
}
