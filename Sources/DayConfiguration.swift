//
//  Created by Dmitry Ivanenko on 19.06.17.
//  Copyright © 2017 Dmitry Ivanenko. All rights reserved.
//

import UIKit


public struct DayConfiguration: PickerConfiguration {
    public var sizeCalculation = SizeCalculationStrategy.adjustedWidth(80)

    // MARK: - Styles

    public var defaultDayStyle: DayStyleConfiguration = {
        var configuration = DayStyleConfiguration()
        
        configuration.dateTextFont = .systemFont(ofSize: 20, weight: UIFont.Weight.thin)
        configuration.dateTextColor = .black
        
        configuration.weekDayTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.thin)
        configuration.weekDayTextColor = .black
        
        configuration.monthTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.light)
        configuration.monthTextColor = .gray
        
        configuration.selectorColor = .clear
        configuration.backgroundColor = .clear
        
        return configuration
    }()
    
    public var weekendDayStyle: DayStyleConfiguration = {
        var configuration = DayStyleConfiguration()
        configuration.weekDayTextFont = .systemFont(ofSize: 8, weight: UIFont.Weight.bold)
        return configuration
    }()
    
    public var selectedDayStyle: DayStyleConfiguration = {
        return DayStyleConfiguration()
    }()
    
    // MARK: - Initializer
    public init() {
    }


    // MARK: - Methods

    func calculateStyle(isWeekend: Bool, isSelected: Bool) -> PickerStyleConfiguration {
        var style = defaultDayStyle

        if isWeekend {
            style = style.merge(with: weekendDayStyle)
        }

        if isSelected {
            style = style.merge(with: selectedDayStyle)
        }

        return style
    }
}

public struct DayStyleConfiguration: PickerStyleConfiguration {
    
    public var dateTextFont: UIFont?
    public var dateTextColor: UIColor?
    
    public var weekDayTextFont: UIFont?
    public var weekDayTextColor: UIColor?
    
    public var monthTextFont: UIFont?
    public var monthTextColor: UIColor?
    
    public var selectorColor: UIColor?
    public var backgroundColor: UIColor?
    
    
    // MARK: - Initializer
    public init() {
    }
    
    
    public func merge(with style: DayStyleConfiguration) -> DayStyleConfiguration {
        var newStyle = DayStyleConfiguration()
        
        newStyle.dateTextFont = style.dateTextFont ?? dateTextFont
        newStyle.dateTextColor = style.dateTextColor ?? dateTextColor
        
        newStyle.weekDayTextFont = style.weekDayTextFont ?? weekDayTextFont
        newStyle.weekDayTextColor = style.weekDayTextColor ?? weekDayTextColor
        
        newStyle.monthTextFont = style.monthTextFont ?? monthTextFont
        newStyle.monthTextColor = style.monthTextColor ?? monthTextColor
        
        newStyle.selectorColor = style.selectorColor ?? selectorColor
        newStyle.backgroundColor = style.backgroundColor ?? backgroundColor
        
        return newStyle
    }
    
}
