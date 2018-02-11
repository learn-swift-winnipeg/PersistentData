//
//  Configuration.swift
//  Persistent Data
//
//  Created by sebastien FOCK CHOW THO on 2018-02-11.
//  Copyright © 2018 sebastien FOCK CHOW THO. All rights reserved.
//

import UIKit


// Color Palette by Paletton.com
// Palette URL: http://paletton.com/#uid=13i0u0kllllaFw0g0qFqFg0w0aF
//
//
// Primary color:
//
// shade 0 = #226666 = rgb( 34,102,102) = rgba( 34,102,102,1) = rgb0(0.133,0.4,0.4)
// shade 1 = #669999 = rgb(102,153,153) = rgba(102,153,153,1) = rgb0(0.4,0.6,0.6)
// shade 2 = #407F7F = rgb( 64,127,127) = rgba( 64,127,127,1) = rgb0(0.251,0.498,0.498)
// shade 3 = #0D4D4D = rgb( 13, 77, 77) = rgba( 13, 77, 77,1) = rgb0(0.051,0.302,0.302)
// shade 4 = #003333 = rgb(  0, 51, 51) = rgba(  0, 51, 51,1) = rgb0(0,0.2,0.2)
//
// Generated by Paletton.com (c) 2002-2014

extension UIColor {
    static let draker = UIColor(red: 0/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    static let dark = UIColor(red: 13/255.0, green: 77/255.0, blue: 77/255.0, alpha: 1.0)
    static let main = UIColor(red: 34/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1.0)
    static let light = UIColor(red: 64/255.0, green: 127/255.0, blue: 127/255.0, alpha: 1.0)
    static let lighter = UIColor(red: 102/255.0, green: 153/255.0, blue: 153/255.0, alpha: 1.0)
}

struct Configuration {
    static let detailedDateFormat = "yyyy-MM-dd HH:mm:ss"
}

extension Date {
    func toStringWithFormat(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}

extension String {
    func toDateWithFormat(_ format: String) -> Date? {
        if self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        
        return formatter.date(from: self)
    }
}

