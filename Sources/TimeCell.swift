//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


class TimeCell: PickerCell {

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

        formatter.dateFormat = "H:mm"
        timeLabel.text = formatter.string(from: date)
        timeLabel.font = style.timeTextFont ?? timeLabel.font
        timeLabel.textColor = style.timeTextColor ?? timeLabel.textColor

        formatter.dateFormat = "a"
        amPmLabel.text = formatter.string(from: date).uppercased()
        amPmLabel.font = style.amPmTextFont ?? amPmLabel.font
        amPmLabel.textColor = style.amPmTextColor ?? amPmLabel.textColor

        formatter.dateFormat = "EEE"
        weekDayLabel.text = formatter.string(from: date).uppercased()
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? UIColor.clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }

}
