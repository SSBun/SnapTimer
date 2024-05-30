//
//  SFSymbols.swift
//  PIP
//
//  Created by caishilin on 2024/5/29.
//

import UIKit
import SwiftUI
import SFSymbolsMacro

@SFSymbol
enum Symbols: String {
    case stopwatch
    case gear
    case calendar_badge_plus = "calendar.badge.plus"
    case list_bullet_clipboard = "list.bullet.clipboard"
    /// calendar.badge.clock
    case calendar_badge_clock = "calendar.badge.clock"
    /// clock.badge.xmark
    case clock_badge_xmark = "clock.badge.xmark"
    /// alarm.waves.left.and.right
    case alarm_waves_left_and_right = "alarm.waves.left.and.right"
    /// calendar
    case calendar
}

extension UIImage {
    static func symbol(_ symbol: Symbols) -> UIImage {
        symbol.uiImage()
    }
}
