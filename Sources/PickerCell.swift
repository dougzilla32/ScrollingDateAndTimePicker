//
//  PickerCell.swift
//  ScrollingDateAndTimePicker
//
//  Created by Doug on 8/21/19.
//  Copyright © 2019 Doug Stein. All rights reserved.
//

import UIKit

protocol PickerCell: UICollectionViewCell {
    associatedtype StyleConfigurationType: PickerStyleConfiguration

    static var ClassName: String { get }
    
    func setup(date: Date, style: PickerStyleConfiguration)
}
