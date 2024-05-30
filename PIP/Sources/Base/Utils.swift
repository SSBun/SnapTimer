//
//  Utils.swift
//  PIP
//
//  Created by caishilin on 2024/5/28.
//

import AVFoundation
import AVKit
import OSLog

extension CMSampleBuffer {
    static func pureColorBuffer(_ color: UIColor, width: Int, height: Int) -> CMSampleBuffer? {
        guard let pixelBuffer = createPixelBuffer(width: width, height: height, color: color) else {
            return nil
        }
        
        guard let sampleBuffer = createSampleBuffer(from: pixelBuffer) else {
            return nil
        }
        
        return sampleBuffer
    }
}

func createPixelBuffer(width: Int, height: Int, color: UIColor) -> CVPixelBuffer? {
    var pixelBuffer: CVPixelBuffer?
    let attributes: [String: Any] = [
        kCVPixelBufferCGImageCompatibilityKey as String: true,
        kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
        kCVPixelBufferIOSurfacePropertiesKey as String: [:],
    ]
    
    let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, attributes as CFDictionary, &pixelBuffer)
    
    guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
        return nil
    }
    
    CVPixelBufferLockBaseAddress(buffer, .readOnly)
    
    let baseAddress = CVPixelBufferGetBaseAddress(buffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
    let bufferPointer = baseAddress?.assumingMemoryBound(to: UInt8.self)
    
    // Get the RGBA components of the UIColor
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    
    let r = UInt8(red * 255)
    let g = UInt8(green * 255)
    let b = UInt8(blue * 255)
    let a = UInt8(alpha * 255)
    
    for y in 0 ..< height {
        for x in 0 ..< width {
            let pixelIndex = y * bytesPerRow + x * 4
            bufferPointer?[pixelIndex] = b // Blue
            bufferPointer?[pixelIndex + 1] = g // Green
            bufferPointer?[pixelIndex + 2] = r // Red
            bufferPointer?[pixelIndex + 3] = a // Alpha
        }
    }
    
    CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
    
    return buffer
}

func createSampleBuffer(from pixelBuffer: CVPixelBuffer) -> CMSampleBuffer? {
    var sampleBuffer: CMSampleBuffer?
    var timingInfo = CMSampleTimingInfo()
    timingInfo.presentationTimeStamp = CMTime.zero
    timingInfo.duration = CMTime.invalid
    timingInfo.decodeTimeStamp = CMTime.invalid
    
    var videoInfo: CMVideoFormatDescription?
    let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
    
    guard status == noErr, let formatDescription = videoInfo else {
        return nil
    }
    
    let sampleBufferStatus = CMSampleBufferCreateForImageBuffer(
        allocator: kCFAllocatorDefault,
        imageBuffer: pixelBuffer,
        dataReady: true,
        makeDataReadyCallback: nil,
        refcon: nil,
        formatDescription: formatDescription,
        sampleTiming: &timingInfo,
        sampleBufferOut: &sampleBuffer
    )
    
    guard sampleBufferStatus == noErr else {
        return nil
    }
    
    return sampleBuffer
}

extension AVAudioSession {
    func preconfigPIPSession() {
        if AVAudioSession.sharedInstance().category == .playAndRecord {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            logger.error("Failed to set up audio session: \(error)")
        }
    }
}

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "PIP")

// MARK: - ArrayBuilder

@resultBuilder
public struct ArrayBuilder<Expression> {
    public typealias Component = [Expression]
    
    public static func buildExpression(_ element: Expression) -> Component {
        return [element]
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        guard let component = component else {
            return []
        }
        return component
    }
    
    public static func buildEither(first component: Component) -> Component {
        return component
    }
    
    public static func buildEither(second component: Component) -> Component {
        return component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        return Array(components.joined())
    }
    
    public static func buildBlock(_ components: Component...) -> Component {
        return Array(components.joined())
    }
}

extension String {
    static func local(_ string: String) -> String {
        String(localized: .init(string))
    }
}

// MARK: - Thenable

protocol Thenable {}

extension Thenable {
    @discardableResult
    func then(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Thenable {}
