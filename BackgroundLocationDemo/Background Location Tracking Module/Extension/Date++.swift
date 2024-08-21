//
//  Date++.swift
//  BackgroundLocationDemo
//
//  Created by Shashi Gupta on 21/08/24.
//

import Foundation

extension Date {
    func toLocalTimeString(withFormat format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current // Set to the current local time zone
        dateFormatter.locale = Locale.current // Set to the current locale
        return dateFormatter.string(from: self)
    }
}
