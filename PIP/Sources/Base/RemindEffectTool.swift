//
//  AudioTool.swift
//  PIP
//
//  Created by caishilin on 2024/5/31.
//

import AVFoundation
import UIKit

// MARK: - RemindEffectTool

class RemindEffectTool {
    static let shared = RemindEffectTool()
    
    private let readyItem = AVPlayerItem(url: Bundle.main.url(forResource: "light_di.mp3", withExtension: nil)!)
    private let goItem = AVPlayerItem(url: Bundle.main.url(forResource: "light_dong.mp3", withExtension: nil)!)
    
    private let player = AVPlayer()
    
    private init() {}
    
    func play(_ audio: Audio) {
        switch audio {
        case .ready:
            player.replaceCurrentItem(with: readyItem)
        case .go:
            player.replaceCurrentItem(with: goItem)
        }
        player.seek(to: .zero)
        player.playImmediately(atRate: 1)
    }
    
    func vibrate(_ vibrationLevel: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: vibrationLevel)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Audio

enum Audio {
    case ready
    case go
}
