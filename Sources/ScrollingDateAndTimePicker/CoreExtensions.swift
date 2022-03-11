//
//  CoreExtensions.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 2/24/20.
//  Copyright © 2020 Doug Stein. All rights reserved.
//

import Foundation

extension Date {
    public static var currentDate: Date {
         return Date()
        
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy/MM/dd HH:mm"
//        return formatter.date(from: "2020/02/21 13:30")!
    }
}

func dispatchMainAsync(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.async {
            block()
        }
    }
}
