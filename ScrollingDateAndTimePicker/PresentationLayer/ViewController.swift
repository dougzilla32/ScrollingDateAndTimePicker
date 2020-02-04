//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let continuousSelection = true
    let infiniteScrolling = true

    @IBOutlet weak var picker: ScrollingDateAndTimePicker! {
        didSet {
            picker.continuousSelection = continuousSelection
            picker.selectedDate = Date()

            // DatePicker
            do {
                var dates: [Date]!
                if infiniteScrolling {
                    dates = nil
                }
                else {
                    dates = [Date]()
                    for day in -15...15 {
                        dates.append(Date(timeIntervalSinceNow: Double(day * 86400)))
                    }
                }
                
                picker.dates = dates
                picker.delegate = self

                var configuration = DayConfiguration()
                
                // weekend customization
                configuration.weekendDayStyle.dateTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                configuration.weekendDayStyle.dateTextFont = UIFont.boldSystemFont(ofSize: 20)
                configuration.weekendDayStyle.weekDayTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                
                // selected date customization
                if !continuousSelection {
                    configuration.selectedDayStyle.backgroundColor = UIColor(white: 0.9, alpha: 1)
                }
                
                picker.dateConfiguration = configuration
            }
            
            // TimePicker
            do {
                var times: [Date]!
                if infiniteScrolling {
                    times = nil
                }
                else {
                    times = [Date]()
                    
                    let now = Date()
                    let calendar = Calendar.current
                    
                    var startOfToday = DateComponents()
                    startOfToday.year = calendar.component(.year, from: now)
                    startOfToday.month = calendar.component(.month, from: now)
                    startOfToday.day = calendar.component(.day, from: now)
                    startOfToday.timeZone = TimeZone.current
                    startOfToday.hour = 0
                    startOfToday.minute = 0
                    
                    let startDate = calendar.date(from: startOfToday)!
                    var offset = DateComponents()
                    
                    for day in -14...14 {
                        offset.day = day
                        for hour in 0..<24 {
                            offset.hour = hour
                            for minute in [0,30] {
                                offset.minute = minute
                                times.append(calendar.date(byAdding: offset, to: startDate)!)
                            }
                        }
                    }
                }
                
                picker.times = times
                picker.delegate = self
                
                var configuration = TimeConfiguration()
                
                // selected time customization
                if !continuousSelection {
                    configuration.selectedTimeStyle.backgroundColor = UIColor(white: 0.9, alpha: 1)
                }
                
                picker.timeConfiguration = configuration
                
                picker.magnification = 1.2
            }
        }
    }
    
    @IBOutlet weak var selectedTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.showSelectedTime()
            self.picker.scrollToSelectedDate(animated: false)
        }
    }

    fileprivate func showSelectedTime() {
        guard let selectedTime = picker.selectedDate else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY HH:mm:ss"
        selectedTimeLabel.text = formatter.string(from: selectedTime)
    }
    
    @IBAction func goToCurrentTime(_ sender: UIButton) {
        picker.selectedDate = Date()
        picker.scrollToSelectedDate(animated: true)
        showSelectedTime()
    }

}


// MARK: - ScrollingDateAndTimePickerDelegate

extension ViewController: ScrollingDateAndTimePickerDelegate {
    func datepicker(_ datepicker: ScrollingDateAndTimePicker, didSelectDate date: Date) {
        showSelectedTime()
    }
    
    func timepicker(_ timepicker: ScrollingDateAndTimePicker, didSelectTime time: Date) {
        showSelectedTime()
    }
}
