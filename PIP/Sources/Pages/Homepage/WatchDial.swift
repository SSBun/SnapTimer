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
    
    init(aspectRatio: CGFloat) {
        self.aspectRatio = aspectRatio
        super.init(frame: .zero)
        
        setupUI()
    }
    
    private func setupUI() {
        if appState.useDynamicColor {
            backgroundColor = .systemGroupedBackground
        } else {
            backgroundColor = UIColor(hexString: appState.timeBackgroundColor)
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
        backgroundColor = appState.useDynamicColor ? .systemGroupedBackground : UIColor(hexString: appState.timeBackgroundColor)
        let timeStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .bold)
            $0.color = appState.useDynamicColor ? .label : UIColor(hexString: appState.timeColor)
        }
        
        let millisecondStyle = Style {
            $0.font = UIFont.monospacedDigitSystemFont(ofSize: 80, weight: .bold)
            $0.color = appState.useDynamicColor ? .secondaryLabel : UIColor(hexString: appState.timeMillisecondColor)
        }
        
        let date = Date()
        var dateStr = date.toString(.custom("HH:mm:ss")).set(style: timeStyle)
        if appState.showMilliseconds {
            dateStr = dateStr + date.toString(.custom(appState.showTwoDigitalMilliseconds ? ":SS" : ":S")).set(style: millisecondStyle)
        }
        timeLabel.attributedText =  dateStr
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

//#Preview {
//    NormalClockDial(aspectRatio: 1)
//}
