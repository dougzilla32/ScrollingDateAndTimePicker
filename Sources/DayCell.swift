//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit

class DayCell: PickerCell {
    
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var weekDayLabel: UILabel!
    @IBOutlet public weak var monthLabel: UILabel!
    @IBOutlet public weak var selectorView: UIView!

    static var ClassName: String {
        return String(describing: self)
    }

    // MARK: - Setup

    override func setup(date: Date, style: PickerStyleConfiguration) {
        let style = style as! DayStyleConfiguration
        let formatter = DateFormatter()

        formatter.dateFormat = "dd"
        dateLabel.text = formatter.string(from: date)
        dateLabel.font = style.dateTextFont ?? dateLabel.font
        dateLabel.textColor = style.dateTextColor ?? dateLabel.textColor

        formatter.dateFormat = "EEE"
        weekDayLabel.text = formatter.string(from: date).uppercased()
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        formatter.dateFormat = "MMMM"
        monthLabel.text = formatter.string(from: date).uppercased()
        monthLabel.font = style.monthTextFont ?? monthLabel.font
        monthLabel.textColor = style.monthTextColor ?? monthLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? UIColor.clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }

}
