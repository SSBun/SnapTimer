//
//  PIPCard.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import AVFoundation
import AVKit
import UIKit

// MARK: - PIPCard

class PIPCard: NiblessView {
    typealias ContentView = UIView & PIPContentView
    
    lazy var manager: AVPictureInPictureController = .init(contentSource: .init(sampleBufferDisplayLayer: displayLayer, playbackDelegate: self))
    lazy var displayLayer: AVSampleBufferDisplayLayer = .init()
    
    private var isHavingFrames = false
    private var currentContent: ContentView?
    
    private var activatingPIPWindow: UIWindow?
    
    private var oldFrameWidth: Int = 1
    private var oldFrameHeight: Int = 1
    private var oldFrameColor: UIColor = .clear
    
    var isInPIP: Bool {
        manager.isPictureInPictureActive
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            logger.error("Picture in Picture is not supported on this device")
            return
        }
        
        backgroundColor = .clear
        manager.delegate = self
        
        appState.$autoPIP.bind { [weak self] in
            self?.manager.canStartPictureInPictureAutomaticallyFromInline = $0
        }.disposed(by: disposeBag)
        
        manager.delegate = self
        displayLayer.backgroundColor = UIColor.clear.cgColor
        displayLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(displayLayer)
        manager.requiresLinearPlayback = true
        manager.setValue(1, forKey: "controlsStyle")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Check if the user interface style has changed
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateLayout(width: oldFrameWidth, height: oldFrameHeight, color: oldFrameColor)
        }
    }
    
    func updateLayout(width: Int, height: Int, color: UIColor) {
        AVAudioSession.sharedInstance().preconfigPIPSession()
        
        guard let sampleBuffer = CMSampleBuffer.pureColorBuffer(color, width: width, height: height) else {
            logger.info("Failed to generate sample buffer")
            return
        }
        
        oldFrameWidth = width
        oldFrameHeight = height
        oldFrameColor = color
        displayLayer.backgroundColor = color.cgColor
        displayLayer.flush()
        displayLayer.enqueue(sampleBuffer)
        isHavingFrames = true
    }
    
    func update(content: ContentView) {
        if let currentContent {
            currentContent.willBeRemovedFromCard()
            currentContent.removeFromSuperview()
            currentContent.didBeRemovedFromCard()
        }
        currentContent = content
        relayoutContent()
    }
    
    func toggle(inPIP: Bool?) {
        guard isHavingFrames else {
            logger.error("No frames to play, please call 'updateFrame(width:height:color:)")
            return
        }
        let inPIP = inPIP ?? !manager.isPictureInPictureActive
        if inPIP {
            manager.startPictureInPicture()
        } else {
            manager.stopPictureInPicture()
        }
    }
    
    
    private func relayoutContent() {
        guard let currentContent else {
            logger.error("Failed to get currentContent")
            return
        }
        if isInPIP {
            guard let activatingPIPWindow else {
                logger.error("Failed to get activatingPIPWindow")
                return
            }
            activatingPIPWindow.addSubview(currentContent)
            currentContent.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
        } else {
            addSubview(currentContent)
            currentContent.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        displayLayer.frame = bounds
    }
}

// MARK: AVPictureInPictureControllerDelegate

extension PIPCard: AVPictureInPictureControllerDelegate {
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        appState.previewInPIP = true
        activatingPIPWindow = UIApplication.shared.windows.first
        relayoutContent()
        currentContent?.didEnterPIP()
    }
    
    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        appState.previewInPIP = false
        activatingPIPWindow = nil
        relayoutContent()
        currentContent?.didExitPIP()
    }
}

// MARK: AVPictureInPictureSampleBufferPlaybackDelegate

extension PIPCard: AVPictureInPictureSampleBufferPlaybackDelegate {
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        setPlaying playing: Bool
    ) {}
    
    func pictureInPictureControllerTimeRangeForPlayback(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> CMTimeRange {
        .init(start: .zero, duration: .init(value: 10, timescale: 1))
    }
    
    func pictureInPictureControllerIsPlaybackPaused(
        _ pictureInPictureController: AVPictureInPictureController
    ) -> Bool {
        false
    }
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        didTransitionToRenderSize newRenderSize: CMVideoDimensions
    ) {}
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime
    ) async {}
    
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("failedToStartPictureInPictureWithError: \(error)")
    }
}

protocol PIPContentView {
    func didEnterPIP()
    func didExitPIP()
    func willBeRemovedFromCard()
    func didBeRemovedFromCard()
    func sizeUpdated(to newSize: CGSize)
}

#Preview {
    let rootView = UIView()
    rootView.backgroundColor = .systemBackground
    let card = PIPCard(frame: .init(origin: .zero, size: .init(width: 100, height: 100)))
    rootView.addSubview(card)
    card.snp.makeConstraints {
        $0.width.height.equalTo(100)
        $0.center.equalToSuperview()
    }
    return rootView
}
