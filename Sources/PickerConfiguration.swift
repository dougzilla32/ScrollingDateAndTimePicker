//
//  PickerConfiguration.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

protocol PickerConfiguration {
    var sizeCalculation: SizeCalculationStrategy { get set }
    
    func calculateStyle(isWeekend: Bool, isSelected: Bool, isCurrent: Bool) -> PickerStyleConfiguration
}

protocol PickerStyleConfiguration {
}

public enum SizeCalculationStrategy {
    case constantWidth(CGFloat)
    case adjustedWidth(CGFloat)
    case numberOfVisibleItems(Int)
    
    func calculateItemSize(frame: CGRect) -> CGSize {
        let itemWidth: CGFloat
        switch self {
        case .constantWidth(let width):
            itemWidth = width
            break
        case .adjustedWidth(let width):
            let percent = 1.0 + max(0.0, frame.width / 484.0 - 1.0) / 2.0
            var numItems = round(frame.width / (width * percent))
            if Int(numItems) % 2 == 0 {
                numItems -= 1.0
            }
            itemWidth = frame.width / max(1.0, numItems)
            break
        case .numberOfVisibleItems(let count):
            itemWidth = frame.width / CGFloat(count)
            break
        }
        return CGSize(width: itemWidth, height: frame.height)
    }
}
