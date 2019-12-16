//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit

public class TimeCell: PickerCell {
    var showTimeRange = false

    @IBOutlet public weak var timeLabel: UILabel!
    @IBOutlet public weak var amPmLabel: UILabel!
    @IBOutlet public weak var weekDayLabel: UILabel!
    @IBOutlet public weak var selectorView: UIView!

    static var ClassName: String {
        return String(describing: self)
    }

    // MARK: - Setup

    override func setup(date: Date, style: PickerStyleConfiguration) {
        let style = style as! TimeStyleConfiguration
        let formatter = DateFormatter()
        let datePlusHour: Date? = (showTimeRange ? date.addingTimeInterval(60 * 60) : nil)

        if let dph = datePlusHour {
            formatter.dateFormat = "h"
            timeLabel.text = "\(formatter.string(from: date))-\(formatter.string(from: dph))"
        }
        else {
            formatter.dateFormat = "h:mm"
            timeLabel.text = formatter.string(from: date)
        }
        timeLabel.font = style.timeTextFont ?? timeLabel.font
        timeLabel.textColor = style.timeTextColor ?? timeLabel.textColor

        formatter.dateFormat = "a"
        amPmLabel.text = formatter.string(from: datePlusHour ?? date).uppercased()
        amPmLabel.font = style.amPmTextFont ?? amPmLabel.font
        amPmLabel.textColor = style.amPmTextColor ?? amPmLabel.textColor

        formatter.dateFormat = "EEE"
        weekDayLabel.text = formatter.string(from: date).uppercased()
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? .clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }
}
