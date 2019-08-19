//
//  Created by Dmitry Ivanenko on 01.10.16.
//  Copyright © 2016 Dmitry Ivanenko. All rights reserved.
//

import UIKit


class ViewController: UIViewController {

    @IBOutlet weak var picker: ScrollingDateAndTimePicker! {
        didSet {
            // DatePicker
            do {
                var dates = [Date]()
                for day in -15...15 {
                    dates.append(Date(timeIntervalSinceNow: Double(day * 86400)))
                }
                
                picker.datePicker.dates = dates
                picker.datePicker.selectedDate = Date()
                picker.delegate = self

                var configuration = DayConfiguration()
                
                // weekend customization
                configuration.weekendDayStyle.dateTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                configuration.weekendDayStyle.dateTextFont = UIFont.boldSystemFont(ofSize: 20)
                configuration.weekendDayStyle.weekDayTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                
                // selected date customization
                configuration.selectedDayStyle.backgroundColor = UIColor(white: 0.9, alpha: 1)
                configuration.daySizeCalculation = .numberOfVisibleItems(5)
                
                picker.datePicker.configuration = configuration
            }
            
            // TimePicker
            do {
                var times = [Date]()
                
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
                        for minute in [0,15,30,45] {
                            offset.minute = minute
                            times.append(calendar.date(byAdding: offset, to: startDate)!)
                        }
                    }
                }
                
                picker.timePicker.times = times
                picker.timePicker.selectedTime = Date()
                picker.delegate = self
                
                var configuration = TimeConfiguration()
                
                // weekend customization
                configuration.weekendTimeStyle.timeTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                configuration.weekendTimeStyle.timeTextFont = UIFont.boldSystemFont(ofSize: 20)
                configuration.weekendTimeStyle.amPmTextColor = UIColor(red: 242.0/255.0, green: 93.0/255.0, blue: 28.0/255.0, alpha: 1.0)
                
                // selected time customization
                configuration.selectedTimeStyle.backgroundColor = UIColor(white: 0.9, alpha: 1)
                configuration.timeSizeCalculation = .numberOfVisibleItems(5)
                
                picker.timePicker.configuration = configuration
            }
        }
    }
    
    @IBOutlet weak var selectedTimeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.async {
            self.showSelectedTime()
            self.picker.timePicker.scrollToSelectedTime(animated: false)
        }
    }

    fileprivate func showSelectedTime() {
        guard let selectedTime = picker.timePicker.selectedTime else {
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY HH:mm:ss"
        selectedTimeLabel.text = formatter.string(from: selectedTime)
    }
    
    @IBAction func goToCurrentTime(_ sender: UIButton) {
        picker.datePicker.selectedDate = Date()
        picker.timePicker.selectedTime = Date()
        picker.datePicker.scrollToSelectedDate(animated: true)
        picker.timePicker.scrollToSelectedTime(animated: true)
        showSelectedTime()
    }

}


// MARK: - ScrollingDateAndTimePickerDelegate

extension ViewController: ScrollingDateAndTimePickerDelegate {
    func datepicker(_ datepicker: DatePicker, didSelectDate date: Date) {
        showSelectedTime()
    }
    
    func timepicker(_ timepicker: TimePicker, didSelectTime time: Date) {
        showSelectedTime()
    }
}
