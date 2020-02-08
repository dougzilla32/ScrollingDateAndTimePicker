//
//  Picker.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

public class Picker: UICollectionView {
    // MARK: - subclasses must override these
    
    var xibClass: AnyClass { fatalError() }
    var infiniteScrollCount: Int { fatalError() }
    func infiniteScrollDate(at index: Int, anchorDate: Date) -> Date { fatalError() }
    func infiniteScrollIndex(of date: Date, anchorDate: Date) -> Int { fatalError() }
    func truncate(date: Date) -> Date { fatalError() }
    func didSelect(date: Date) { fatalError() }
    func dequeueReusableCell(_: UICollectionView, for: IndexPath) -> PickerCell { fatalError() }
    func configureCell(_ cell: PickerCell, date: Date, isWeekend: Bool, isSelected: Bool, isHighlighted: Bool) { fatalError() }
    func isCurrent(date: Date) -> Bool { fatalError() }

    // MARK: - properties and methods
    
    weak var parent: ScrollingDateAndTimePicker!
    weak var magnifier: MagnifierView!
    weak var pickerDelegate: ScrollingDateAndTimePickerDelegate!
    var progressLayer: TAProgressLayer?

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
        if cachedFrameWidth != frame.width {
            let itemSize = configuration.sizeCalculation.calculateItemSize(frame: frame)
            cachedFrameWidth = frame.width
            cachedItemWidth = itemSize.width
            let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
            if itemSize != layout.itemSize {
                layout.itemSize = itemSize
            }
        }

        super.layoutSubviews()

        if parent?.isHighlightingEnabled ?? false {
            let maskView = MaskingView(frame: self.bounds)
            maskView.itemWidth = cachedItemWidth
            maskView.backgroundColor = .clear
            self.mask = maskView
        }
        else {
            self.mask = nil
        }
    }
    
    private class MaskingView: UIView {
        var itemWidth: CGFloat?
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)

            guard let context = UIGraphicsGetCurrentContext(), let itemWidth = self.itemWidth else { return }

            context.setStrokeColor(UIColor.white.cgColor)
            context.addRect(CGRect(x: 0, y: 0, width: (self.frame.size.width - itemWidth) / 2, height: self.bounds.size.height))
            context.fillPath()
            context.addRect(CGRect(x: (self.frame.size.width + itemWidth) / 2, y: 0, width: (self.frame.size.width - itemWidth) / 2, height: self.bounds.size.height))
            context.fillPath()
        }
    }

    override public func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool) {
        guard magnifier?.magnification != nil || (parent?.isHighlightingEnabled ?? false) else {
            super.scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            return
        }
        
        if animated {
            let startOffset = contentOffset
            super.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            let endOffset = contentOffset
            contentOffset = startOffset

            self.progressLayer?.cancel()
            let progressLayer = TAProgressLayer(layer: magnifier.layer, progressDelegate: PickerProgressDelegate(picker: self, startOffset: startOffset, endOffset: endOffset))
            self.progressLayer = progressLayer

            do {
                let anim = CABasicAnimation(keyPath: TAProgressLayer.ProgressKey)
                anim.duration = 0.3
                anim.beginTime = 0
                anim.fromValue = CGFloat(0)
                anim.toValue = CGFloat(1)
                anim.fillMode = .forwards
                anim.isRemovedOnCompletion = false
                anim.delegate = TAProgressAnimationDelegate(progressLayer: progressLayer)
                anim.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
                progressLayer.add(anim, forKey: TAProgressLayer.ProgressKey)
            }
        }
        else {
            super.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
            
            // Wait until picker layer is updated before updating the magnifier layer -- couldn't figure out
            // a better way to do this.
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
                self.updateMagnifier()
            }
        }
    }
    
    var leftHighlightCell: PickerCell!
    var rightHighlightCell: PickerCell!

    func updateMagnifier() {
        guard let magnifier = self.magnifier else { return }
        
        if parent?.isHighlightingEnabled ?? false {
            magnifier.clipsToBounds = true
            
            let addCell: (PickerCell?) -> PickerCell = { currentCell in
                let cell = currentCell ?? (LoadableFromXibView.xibView(bundleClass: ScrollingDateAndTimePicker.self, viewClass: self.xibClass) as! PickerCell)
                if cell.superview == nil {
                    magnifier.addSubview(cell)
                }
                cell.frame = CGRect(x: 0, y: 0, width: magnifier.frame.size.width, height: magnifier.frame.size.height)
                return cell
            }
            leftHighlightCell = addCell(leftHighlightCell)
            rightHighlightCell = addCell(rightHighlightCell)
            
            if magnifier.drawCallback == nil {
                magnifier.drawCallback = unown(self, type(of: self).drawCallback)
            }
            
            magnifier.setNeedsDisplay()
        }
        else {
            magnifier.clipsToBounds = false
            leftHighlightCell?.removeFromSuperview()
            rightHighlightCell?.removeFromSuperview()
            magnifier.drawCallback = nil

            if magnifier.magnification != nil {
                magnifier.touchPoint = CGPoint(
                    x: contentOffset.x + self.frame.size.width / 2,
                    y: contentOffset.y + self.frame.size.height / 2)
                magnifier.setNeedsDisplay()
            }
        }
    }
    
    private func drawCallback(_ rect: CGRect) {
        let itemSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize

        let translateCell: (String, PickerCell, Int?, CGFloat, CGFloat) -> Int? = { msg, cell, index, superX, cellX in
            let io = Picker.indexAndOffset(x: superX + cellX, cellWidth: itemSize.width)
            guard io.index != index else {
                cell.isHidden = true
                return nil
            }
            cell.isHidden = false

            let date = self.date(at: io.index)
            self.setup(cell: cell, date: date, isHighlighted: true)
            cell.frame.origin = CGPoint(x: cellX - io.offset, y: 0.0)
            return io.index
        }
        
        let superX = self.contentOffset.x + magnifier.frame.origin.x
        let leftIndex = translateCell("leftHighlightCell", leftHighlightCell, nil, superX, 0)
        let _ = translateCell("rightHighlightCell", rightHighlightCell, leftIndex, superX, magnifier.frame.size.width)
    }
    
    private static func indexAndOffset(x: CGFloat, cellWidth: CGFloat) -> (index: Int, offset: CGFloat) {
        return (
            index: Int((x / cellWidth).rounded(.towardZero)),
            offset: x.truncatingRemainder(dividingBy: cellWidth))
    }
}

// How to avoid implicit retain cycles when using function references
// https://sveinhal.github.io/2016/03/16/retain-cycles-function-references/
func unown<T: AnyObject, U, V>(_ instance: T, _ classFunction: @escaping (T)->(U)->V) -> (U)->V {
    return { [unowned instance] args in
        let instanceFunction = classFunction(instance)
        return instanceFunction(args)
    }
}

class PickerProgressDelegate: TAProgressDelegate {
    weak var picker: Picker?
    let startOffset: CGPoint
    let endOffset: CGPoint
    
    init(picker: Picker, startOffset: CGPoint, endOffset: CGPoint) {
        self.picker = picker
        self.startOffset = startOffset
        self.endOffset = endOffset
    }

    func progressUpdated(_ progress: CGFloat) {
        picker?.contentOffset = CGPoint(
            x: startOffset.x + (endOffset.x - startOffset.x) * progress,
            y: startOffset.y + (endOffset.y - startOffset.y) * progress)
        picker?.updateMagnifier()
    }
}

// MARK: - UICollectionViewDataSource

extension Picker: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates?.count ?? infiniteScrollCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dequeueReusableCell(collectionView, for: indexPath)
        let date = self.date(at: indexPath.item)
        if isSelected(date: date) {
            prevSelectedIndex = indexPath.item
        }
        setup(cell: cell, date: date, isHighlighted: false)
        return cell
    }
    
    private func setup(cell: PickerCell, date: Date, isHighlighted: Bool) {
        let isWeekendDate = isWeekday(date: date)
        let isSelectedDate = isSelected(date: date)
        let isCurrentDate = isCurrent(date: date)

        cell.setup(
            date: date,
            style: configuration.calculateStyle(
                isWeekend: isWeekendDate,
                isSelected: isSelectedDate,
                isCurrent: isCurrentDate,
                isHighlighted: isHighlighted),
            showTimeRange: parent?.showTimeRange ?? false)
        
        configureCell(cell, date: date, isWeekend: isWeekendDate, isSelected: isSelectedDate, isHighlighted: isHighlighted)
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
        
        updateMagnifier()
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

extension Date {
    var isCurrentDay: Bool {
        return Calendar.current.component(.day, from: Date()) == Calendar.current.component(.day, from: self)
    }
    
    var isCurrentHour: Bool {
        return Calendar.current.component(.hour, from: Date()) == Calendar.current.component(.hour, from: self)
    }
}
