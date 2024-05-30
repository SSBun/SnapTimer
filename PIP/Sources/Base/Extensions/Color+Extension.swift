//
//  Color+Extension.swift
//  PIP
//
//  Created by caishilin on 2024/5/30.
//

import UIKit

extension UIColor {
    
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let redInt = Int(red * 255)
        let greenInt = Int(green * 255)
        let blueInt = Int(blue * 255)
        let alphaInt = Int(alpha * 255)
        return String(format: "#%02X%02X%02X%02X", redInt, greenInt, blueInt, alphaInt)
    }
    
    convenience init(hexString: String) {
        var hex = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString
        guard hex.count == 6 || hex.count == 8 else {
            self.init(white: 0, alpha: 0)
            return
        }
        if hex.count == 6 {
            hex += "FF"
        }
        let scanner = Scanner(string: hex)
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgb & 0x000000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
