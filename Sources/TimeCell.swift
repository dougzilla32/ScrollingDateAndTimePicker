//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit

public protocol DateText {
    var time: String { get }
    var startTime: String? { get }
    var endTime: String? { get }
    var weekDay: String { get }
    var amPm: String { get }
    var noon: String? { get }
    var midnight: String? { get }
}

private struct MutableDateText: DateText {
    public var time: String
    public var startTime: String?
    public var endTime: String?
    public var weekDay: String
    public var amPm: String
    public var noon: String?
    public var midnight: String?
    
    public static var emptyDateText: MutableDateText {
        return MutableDateText(time: "", startTime: nil, endTime: nil, weekDay: "", amPm: "", noon: nil, midnight: nil)
    }
}

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

    public static func text(forDate date: Date, showTimeRange: Bool) -> DateText {
        var text = MutableDateText.emptyDateText
        let formatter = DateFormatter()
        let datePlusHour: Date? = (showTimeRange ? date.addingTimeInterval(60 * 60) : nil)

        if let dph = datePlusHour {
            formatter.dateFormat = "h"
            let startTime = formatter.string(from: date)
            let endTime = formatter.string(from: dph)
            text.time = "\(startTime)-\(endTime)"

            formatter.dateFormat = "a"
            text.startTime = "\(startTime)\(formatter.string(from: date))"
            text.endTime = "\(endTime)\(formatter.string(from: dph))"
        }
        else {
            formatter.dateFormat = "h:mm"
            text.time = formatter.string(from: date)
        }

        formatter.dateFormat = "a"
        text.amPm = formatter.string(from: datePlusHour ?? date)

        formatter.dateFormat = "EEE"
        text.weekDay = formatter.string(from: date)

        if showTimeRange && text.time == "11-12" {
            if text.amPm == "PM" {
                text.noon = "NOON"
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
                text.midnight = TimeCell.Moons[Int(round(phase * 8))]
            }
        }

        return text
    }

    // MARK: - Setup

    override func setup(date: Date, style: PickerStyleConfiguration) {
        let style = style as! TimeStyleConfiguration
        let dateText = TimeCell.text(forDate: date, showTimeRange: showTimeRange)

        timeLabel.text = dateText.time
        timeLabel.font = style.timeTextFont ?? timeLabel.font
        timeLabel.textColor = style.timeTextColor ?? timeLabel.textColor

        let defaultFont = style.amPmTextFont ?? amPmLabel.font
        let defaultPointSize = defaultFont?.pointSize ?? 8.0
        if let noon = dateText.noon {
            amPmLabel.text = noon
            amPmLabel.font = .systemFont(ofSize: defaultPointSize, weight: .medium)
        }
        else if let midnight = dateText.midnight {
            amPmLabel.text = midnight
            amPmLabel.font = .systemFont(ofSize: defaultPointSize + 7.0, weight: .thin)
        }
        else {
            amPmLabel.text = dateText.amPm
            amPmLabel.font = defaultFont
        }
        amPmLabel.textColor = style.amPmTextColor ?? amPmLabel.textColor

        weekDayLabel.text = dateText.weekDay.uppercased()
        weekDayLabel.font = style.weekDayTextFont ?? weekDayLabel.font
        weekDayLabel.textColor = style.weekDayTextColor ?? weekDayLabel.textColor

        selectorView.backgroundColor = style.selectorColor ?? .clear
        backgroundColor = style.backgroundColor ?? backgroundColor
    }
}
