//
//  TimeConfiguration.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public struct TimeConfiguration: PickerConfiguration {
    public var sizeCalculation = SizeCalculationStrategy.adjustedWidth(80)

    public var defaultTimeStyle: TimeStyleConfiguration = {
        var configuration = TimeStyleConfiguration()
        
        configuration.timeTextFont = .systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        configuration.timeTextColor = .black
        
        configuration.amPmTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.thin)
        configuration.amPmTextColor = .black
        
        configuration.weekDayTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.light)
        configuration.weekDayTextColor = .gray
        
        configuration.selectorColor = .clear
        configuration.backgroundColor = .clear
        
        return configuration
    }()
    
    public var weekendTimeStyle: TimeStyleConfiguration = {
        return TimeStyleConfiguration()
    }()
    
    public var selectedTimeStyle: TimeStyleConfiguration = {
        return TimeStyleConfiguration()
    }()
    
    
    // MARK: - Methods
    
    func calculateStyle(isWeekend: Bool, isSelected: Bool) -> PickerStyleConfiguration {
        var style = defaultTimeStyle
        
        if isWeekend {
            style = style.merge(with: weekendTimeStyle)
        }
        
        if isSelected {
            style = style.merge(with: selectedTimeStyle)
        }
        
        return style
    }

}

public struct TimeStyleConfiguration: PickerStyleConfiguration {
    
    public var timeTextFont: UIFont?
    public var timeTextColor: UIColor?
    
    public var amPmTextFont: UIFont?
    public var amPmTextColor: UIColor?
    
    public var weekDayTextFont: UIFont?
    public var weekDayTextColor: UIColor?
    
    public var selectorColor: UIColor?
    public var backgroundColor: UIColor?
    
    
    // MARK: - Initializer
    public init() {
    }
    
    
    public func merge(with style: TimeStyleConfiguration) -> TimeStyleConfiguration {
        var newStyle = TimeStyleConfiguration()
        
        newStyle.timeTextFont = style.timeTextFont ?? timeTextFont
        newStyle.timeTextColor = style.timeTextColor ?? timeTextColor
        
        newStyle.amPmTextFont = style.amPmTextFont ?? amPmTextFont
        newStyle.amPmTextColor = style.amPmTextColor ?? amPmTextColor
        
        newStyle.weekDayTextFont = style.weekDayTextFont ?? weekDayTextFont
        newStyle.weekDayTextColor = style.weekDayTextColor ?? weekDayTextColor
        
        newStyle.selectorColor = style.selectorColor ?? selectorColor
        newStyle.backgroundColor = style.backgroundColor ?? backgroundColor
        
        return newStyle
    }
    
}
