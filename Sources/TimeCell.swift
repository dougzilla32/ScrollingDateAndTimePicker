//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


open class TimeCell: UICollectionViewCell {

    @IBOutlet public weak var timeLabel: UILabel!
    @IBOutlet public weak var amPmLabel: UILabel!
    @IBOutlet public weak var weekDayLabel: UILabel!
    @IBOutlet public weak var selectorView: UIView!

    static var ClassName: String {
        return String(describing: self)
    }


    // MARK: - Setup

    func setup(time: Date, style: TimeStyleConfiguration) {
        let formatter = DateFormatter()

        formatter.dateFormat = "HH:mm"
        timeLabel.text = formatter.string(from: time)
        timeLabel.font = style.timeTextFont ?? timeLabel.font
        timeLabel.textColor = style.timeTextColor ?? timeLabel.textColor

        formatter.dateFormat = "a"
        amPmLabel.text = formatter.string(from: time).uppercased()
        amPmLabel.font = style.amPmTextFont ?? amPmLabel.font
        amPmLabel.textColor = style.amPmTextColor ?? amPmLabel.textColor

        formatter.dateFormat = "EEE"
        weekDayLabel.text = formatter.string(from: time).uppercased()
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? UIColor.clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }

}
