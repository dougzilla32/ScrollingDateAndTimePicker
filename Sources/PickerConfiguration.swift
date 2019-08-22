//
//  PickerConfiguration.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//

import UIKit

protocol PickerConfiguration {
    var sizeCalculation: SizeCalculationStrategy { get set }
    
    func calculateStyle(isWeekend: Bool, isSelected: Bool) -> PickerStyleConfiguration
}

protocol PickerStyleConfiguration {
}

public enum SizeCalculationStrategy {
    case constantWidth(CGFloat)
    case numberOfVisibleItems(Int)
}
