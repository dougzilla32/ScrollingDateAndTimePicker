//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit

public class TimeCell: PickerCell {
    static let Moons = ["🌑", "🌒", " 🌓", "🌔", "🌕", "🌖", "🌗", "🌘", "🌑"]
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
        
        if showTimeRange && timeLabel.text == "11-12" {
            if amPmLabel.text == "PM" {
                amPmLabel.text = "NOON"
                amPmLabel.font = .systemFont(ofSize: 8.0, weight: .medium)
            } else {
                var phase = Moon.shared.illumination(date: date).phase
                // Show new moon and full moon less often, because this better matches
                // the actual appearance in the sky.
                switch phase {
                case 0.045...0.125:
                    phase = 0.126
                case 0.375...0.455:
                    phase = 0.374
                case 0.545...0.625:
                    phase = 0.626
                case 0.875...0.955:
                    phase = 0.874
                default:
                    break
                }
                amPmLabel.text = TimeCell.Moons[Int(round(phase * 8))]
                amPmLabel.font = .systemFont(ofSize: 15.0, weight: .thin)
            }
        }
        else {
            amPmLabel.font = .systemFont(ofSize: 8.0, weight: .thin)
        }
    }
}
