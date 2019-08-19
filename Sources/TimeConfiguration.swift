//
//  TimeConfiguration.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/19/19.
//

import UIKit

public struct TimeConfiguration {

    public enum TimeSizeCalculationStrategy {
        case constantWidth(CGFloat)
        case numberOfVisibleItems(Int)
    }
    
    public var timeSizeCalculation: TimeSizeCalculationStrategy = TimeSizeCalculationStrategy.numberOfVisibleItems(5)
    
    
    public var defaultTimeStyle: TimeStyleConfiguration = {
        var configuration = TimeStyleConfiguration()
        
        configuration.timeTextFont = .systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        configuration.timeTextColor = .black
        
        configuration.amPmTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.thin)
        configuration.amPmTextColor = .black
        
        configuration.weekDayTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.light)
        configuration.weekDayTextColor = .gray
        
        configuration.selectorColor = .clear
        configuration.backgroundColor = .white
        
        return configuration
    }()
    
    public var weekendTimeStyle: TimeStyleConfiguration = {
        var configuration = TimeStyleConfiguration()
        configuration.amPmTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.bold)
        return configuration
    }()
    
    public var selectedTimeStyle: TimeStyleConfiguration = {
        var configuration = TimeStyleConfiguration()
        configuration.selectorColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
        return configuration
    }()
    
    
    // MARK: - Methods
    
    func calculateTimeStyle(isWeekend: Bool, isSelected: Bool) -> TimeStyleConfiguration {
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

public struct TimeStyleConfiguration {
    
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
