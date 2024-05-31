//
//  AppStore.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit

// MARK: - CardStyle

enum CardStyle: Int, CustomStringConvertible, CaseIterable, Codable {
    case normal
    case medium
    case large
    
    var description: String {
        switch self {
        case .normal:
            return "Normal"
        case .medium:
            return "Medium"
        case .large:
            return "Large"
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .normal:
            return 10
        case .medium:
            return 4
        case .large:
            return 1
        }
    }
}

let appState = AppState()

// MARK: - AppState

class AppState {
    fileprivate init() {}
    
    @LocalStorageState(key: "selectedCardStyle")
    var selectedCardStyle: CardStyle = .normal
    
    @State
    var previewInPIP: Bool = false
    
    /// Auto enter PIP when the app goes to the background
    @LocalStorageState(key: "autoPIP")
    var autoPIP: Bool = false
    
    @LocalStorageState(key: "buyPlans")
    var plans: [BuyPlan] = []
    
    /// showMilliseconds
    @LocalStorageState(key: "showMilliseconds")
    var showMilliseconds: Bool = false
    
    @LocalStorageState(key: "showTwoDigitalMilliseconds")
    var showTwoDigitalMilliseconds: Bool = false
    
    /// timeColor
    @LocalStorageState(key: "timeColor")
    var timeColor: String = UIColor.label.hexString
    
    /// timeMillisecondColor
    @LocalStorageState(key: "timeMillisecondColor")
    var timeMillisecondColor: String = UIColor.secondaryLabel.hexString
    
    /// timeBackgroundColor
    @LocalStorageState(key: "timeBackgroundColor")
    var timeBackgroundColor: String = UIColor.systemGroupedBackground.hexString
    
    @LocalStorageState(key: "useDynamicColor")
    var useDynamicColor: Bool = true
    
    @LocalStorageState(key: "showTimerReminder")
    var showTimerReminder: Bool = true
    
    @LocalStorageState(key: "timerRemindOffset")
    var timerRemindOffset: Int = 0
    
    let remindConfig = RemindConfig()
}

extension AppState {
    class RemindConfig {
        fileprivate init() {}
        
        @LocalStorageState(key: "RemindConfig.enableAudioEffect")
        var enableAudioEffect: Bool = false
        
        @LocalStorageState(key: "RemindConfig.enableVibrationEffect")
        var enableVibrationEffect: Bool = false
    }
}
