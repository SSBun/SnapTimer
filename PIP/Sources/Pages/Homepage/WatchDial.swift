//
//  WatchDial.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import UIKit
import SnapKit
import SwiftRichString

protocol WatchDial {
    var aspectRatio: CGFloat { get }
    var fillColor: UIColor { get }
}

class NormalClockDial: NiblessView, WatchDial {
    let timeLabel = UILabel()
    let aspectRatio: CGFloat
    
    private var displayLink: CADisplayLink?
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
    }
    
    private var lastSeconds: Int?
    
    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
        super.init(frame: .zero)
        
        setupUI()
    }
    
    private func setupUI() {
        if appState.useDynamicColor {
            backgroundColor = .systemGroupedBackground
        } else {
            backgroundColor = .hex(appState.timeBackgroundColor)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stackView.distribution = .fillEqually
        for _ in 0...2 {
            let lightView = UIView()
            stackView.addArrangedSubview(lightView)
        }
        
        addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        timeLabel.textColor = .label
        timeLabel.textAlignment = .center
        timeLabel.adjustsFontSizeToFitWidth = true
        timeLabel.minimumScaleFactor = 0.1
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateTime))
        displayLink?.preferredFrameRateRange = .init(minimum: 30, maximum: 30)
        displayLink?.add(to: .main, forMode: .common)
    }
    
    var fillColor: UIColor {
        return .clear
    }
    
    @objc private func updateTime() {
        backgroundColor = appState.useDynamicColor ? .systemGroupedBackground : .hex(appState.timeBackgroundColor)
        let timeStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .bold)
            $0.color = appState.useDynamicColor ? .label : UIColor.hex(appState.timeColor)
        }
        
        let millisecondStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .bold)
            $0.color = appState.useDynamicColor ? .secondaryLabel : UIColor.hex(appState.timeMillisecondColor)
        }
        
        let date = Date()
        var dateStr = date.toString(.custom("HH:mm:ss")).set(style: timeStyle)
        if appState.showMilliseconds {
            dateStr = dateStr + date.toString(.custom(appState.showTwoDigitalMilliseconds ? ":SS" : ":S")).set(style: millisecondStyle)
        }
        timeLabel.attributedText =  dateStr
        
        let second = date.second
        let millisecond = date.nanosecond / 1_000_000
        let timeOffset = appState.timerRemindOffset
        var hasGone = false
        if appState.showTimerReminder {
            if second == 57 && second != lastSeconds {
                hasGone = false
                stackView.arrangedSubviews[0].backgroundColor = .systemOrange
                triggerEffect(false)
            }
            if second == 58 && second != lastSeconds {
                stackView.arrangedSubviews[1].backgroundColor = .systemOrange
                triggerEffect(false)
            }
            if second == 59 && second != lastSeconds {
                stackView.arrangedSubviews[2].backgroundColor = .systemOrange
                triggerEffect(false)
            }
            if timeOffset == 0 {
                if second == 0 && second != lastSeconds {
                    timeToGo()
                }
            } else {
                if second == 59, !hasGone, timeOffset + millisecond >= 1000 {
                    hasGone = true
                    timeToGo()
                }
            }
        } else {
            self.stackView.arrangedSubviews.forEach({ $0.backgroundColor = .clear })
        }
        lastSeconds = second
    }
    
    private func timeToGo() {
        self.stackView.arrangedSubviews.forEach({ $0.backgroundColor = .systemGreen })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.stackView.arrangedSubviews.forEach({ $0.backgroundColor = .clear })
        }
        triggerEffect(true)
    }
    
    private func triggerEffect(_ isGo: Bool) {
        let audioEnable = appState.remindConfig.enableAudioEffect
        let vibrationEnable = appState.remindConfig.enableVibrationEffect
        if audioEnable { RemindEffectTool.shared.play(isGo ? .go : .ready) }
        if vibrationEnable { RemindEffectTool.shared.vibrate(isGo ? .heavy : .light) }
    }
}

extension NormalClockDial: PIPContentView {
    func didEnterPIP() {
        logger.debug("didEnterPIP")
    }
    
    func didExitPIP() {
        logger.debug("didExitPIP")
    }
    
    func willBeRemovedFromCard() {
        logger.debug("willBeRemovedFromCard")
    }
    
    func didBeRemovedFromCard() {
        logger.debug("didBeRemovedFromCard")
        displayLink?.invalidate()
        displayLink = nil
    }
    
    func sizeUpdated(to newSize: CGSize) {
        let info =  "size updated: \(newSize)"
        logger.debug("\(info)")
    }
}

#Preview {
    NormalClockDial(aspectRatio: 1)
}
