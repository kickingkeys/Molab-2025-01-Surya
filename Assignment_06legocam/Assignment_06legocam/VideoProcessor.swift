//
//  Untitled.swift
//  Assignment_06legocam
//
//  Created by Surya Narreddi on 13/03/25.
//

import AVFoundation
import UIKit
import Photos

class VideoProcessor {
    // Process video with LEGO effect
    static func processVideo(inputURL: URL, legoSize: Int, completion: @escaping (Result<URL, Error>) -> Void) {
        Task {
            do {
                // Create asset from URL
                let asset = AVURLAsset(url: inputURL)
                
                // Create a composition
                let composition = AVMutableComposition()
                
                // Perform loading of tracks before accessing
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                let audioTracks = try await asset.loadTracks(withMediaType: .audio)
                
                // Ensure we have tracks to work with
                guard let videoTrack = videoTracks.first,
                      let compositionVideoTrack = composition.addMutableTrack(
                        withMediaType: .video,
                        preferredTrackID: kCMPersistentTrackID_Invalid),
                      let audioTrack = audioTracks.first,
                      let compositionAudioTrack = composition.addMutableTrack(
                        withMediaType: .audio,
                        preferredTrackID: kCMPersistentTrackID_Invalid) else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create composition tracks"])))
                    return
                }
                
                // Add video and audio to composition
                do {
                    let duration = try await asset.load(.duration)
                    let timeRange = CMTimeRange(start: .zero, duration: duration)
                    try compositionVideoTrack.insertTimeRange(timeRange, of: videoTrack, at: .zero)
                    try compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: .zero)
                } catch {
                    completion(.failure(error))
                    return
                }
                
                // Create LEGO effect video writer
                let tempDir = FileManager.default.temporaryDirectory
                let outputURL = tempDir.appendingPathComponent("LegoProcessed_\(Date().timeIntervalSince1970).mov")
                
                // Create video reader
                guard let reader = try? AVAssetReader(asset: asset) else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create asset reader"])))
                    return
                }
                
                // Get video size
                let naturalSize = try await videoTrack.load(.naturalSize)
                
                // Create output settings
                let videoSettings: [String: Any] = [
                    AVVideoCodecKey: AVVideoCodecType.h264,
                    AVVideoWidthKey: naturalSize.width,
                    AVVideoHeightKey: naturalSize.height
                ]
                
                // Create writer
                guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mov) else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to create asset writer"])))
                    return
                }
                
                // Add video input to writer
                let writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
                writerVideoInput.expectsMediaDataInRealTime = false
                
                if writer.canAdd(writerVideoInput) {
                    writer.add(writerVideoInput)
                } else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 3,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to add video input to writer"])))
                    return
                }
                
                // Add audio input to writer
                let writerAudioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                writerAudioInput.expectsMediaDataInRealTime = false
                
                if writer.canAdd(writerAudioInput) {
                    writer.add(writerAudioInput)
                } else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 4,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to add audio input to writer"])))
                    return
                }
                
                // Add pixel buffer adapter for processing frames
                let pixelBufferAttributes: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                    kCVPixelBufferWidthKey as String: Int(naturalSize.width),
                    kCVPixelBufferHeightKey as String: Int(naturalSize.height)
                ]
                
                let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: writerVideoInput,
                    sourcePixelBufferAttributes: pixelBufferAttributes)
                
                // Set up video reader output
                let readerVideoOutput = AVAssetReaderTrackOutput(
                    track: videoTrack,
                    outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
                
                if reader.canAdd(readerVideoOutput) {
                    reader.add(readerVideoOutput)
                } else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 5,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to add video output to reader"])))
                    return
                }
                
                // Set up audio reader output
                let readerAudioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                
                if reader.canAdd(readerAudioOutput) {
                    reader.add(readerAudioOutput)
                } else {
                    completion(.failure(NSError(
                        domain: "VideoProcessor",
                        code: 6,
                        userInfo: [NSLocalizedDescriptionKey: "Failed to add audio output to reader"])))
                    return
                }
                
                // Start reading and writing
                reader.startReading()
                writer.startWriting()
                writer.startSession(atSourceTime: .zero)
                
                // Process audio samples
                Task {
                    while writerAudioInput.isReadyForMoreMediaData {
                        if let audioSampleBuffer = readerAudioOutput.copyNextSampleBuffer() {
                            writerAudioInput.append(audioSampleBuffer)
                        } else {
                            writerAudioInput.markAsFinished()
                            break
                        }
                    }
                }
                
                // Process video frames with LEGO effect
                Task {
                    var frameCount = 0
                    
                    while writerVideoInput.isReadyForMoreMediaData {
                        if let sampleBuffer = readerVideoOutput.copyNextSampleBuffer(),
                           let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                            
                            // Get timing info
                            let presentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                            
                            // Create CIImage from pixel buffer
                            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                            
                            // Convert to UIImage for LEGO processing
                            let context = CIContext()
                            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { continue }
                            let uiImage = UIImage(cgImage: cgImage)
                            
                            // Apply LEGO effect
                            if let legoImage = applyLegoEffect(to: uiImage, legoSize: legoSize),
                               let legoCGImage = legoImage.cgImage {
                                
                                // Create a pixel buffer for the LEGO image
                                let pixelBufferPool = adaptor.pixelBufferPool
                                var outputPixelBuffer: CVPixelBuffer?
                                
                                CVPixelBufferPoolCreatePixelBuffer(nil, pixelBufferPool!, &outputPixelBuffer)
                                
                                if let outputPixelBuffer = outputPixelBuffer {
                                    CVPixelBufferLockBaseAddress(outputPixelBuffer, [])
                                    
                                    let pixelData = CVPixelBufferGetBaseAddress(outputPixelBuffer)
                                    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
                                    
                                    // Create context for drawing
                                    let context = CGContext(
                                        data: pixelData,
                                        width: CVPixelBufferGetWidth(outputPixelBuffer),
                                        height: CVPixelBufferGetHeight(outputPixelBuffer),
                                        bitsPerComponent: 8,
                                        bytesPerRow: CVPixelBufferGetBytesPerRow(outputPixelBuffer),
                                        space: rgbColorSpace,
                                        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)
                                    
                                    // Draw LEGO image into the pixel buffer
                                    context?.draw(
                                        legoCGImage,
                                        in: CGRect(
                                            x: 0,
                                            y: 0,
                                            width: CVPixelBufferGetWidth(outputPixelBuffer),
                                            height: CVPixelBufferGetHeight(outputPixelBuffer)))
                                    
                                    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, [])
                                    
                                    // Add frame to video
                                    adaptor.append(outputPixelBuffer, withPresentationTime: presentationTime)
                                }
                            }
                            
                            frameCount += 1
                        } else {
                            writerVideoInput.markAsFinished()
                            break
                        }
                    }
                    
                    // Finish writing
                    await writer.finishWriting()
                    if writer.status == .completed {
                        completion(.success(outputURL))
                    } else if let error = writer.error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(NSError(
                            domain: "VideoProcessor",
                            code: 7,
                            userInfo: [NSLocalizedDescriptionKey: "Unknown error during video processing"])))
                    }
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    // Apply LEGO effect to a single image
    static func applyLegoEffect(to image: UIImage, legoSize: Int) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Draw the original image
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Apply LEGO effect
        for y in stride(from: 0, to: height, by: legoSize) {
            for x in stride(from: 0, to: width, by: legoSize) {
                // Sample color from the image at the center of each brick
                let pixelX = min(x + legoSize/2, width - 1)
                let pixelY = min(y + legoSize/2, height - 1)
                
                guard let pixelData = cgImage.dataProvider?.data,
                      let data = CFDataGetBytePtr(pixelData) else { continue }
                
                let pixelIndex = (pixelY * cgImage.bytesPerRow) + (pixelX * 4)
                
                let blue = CGFloat(data[pixelIndex]) / 255.0
                let green = CGFloat(data[pixelIndex + 1]) / 255.0
                let red = CGFloat(data[pixelIndex + 2]) / 255.0
                
                // Draw LEGO brick
                drawLegoBrick(
                    in: context,
                    at: CGPoint(x: x, y: y),
                    size: legoSize,
                    color: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    static private func drawLegoBrick(in context: CGContext, at point: CGPoint, size: Int, color: UIColor) {
        let studSize = CGFloat(size) * 0.4
        let x = point.x
        let y = point.y
        
        // Draw main brick
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: x, y: y, width: CGFloat(size), height: CGFloat(size)))
        
        // Draw stud (circle on top)
        let centerX = x + CGFloat(size) / 2
        let centerY = y + CGFloat(size) / 2
        
        // Darker version for stud shadow
        var darkColor = color
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            darkColor = UIColor(red: r * 0.8, green: g * 0.8, blue: b * 0.8, alpha: a)
        }
        
        // Lighter version for stud top
        var lightColor = color
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            lightColor = UIColor(
                red: min(r * 1.1, 1.0),
                green: min(g * 1.1, 1.0),
                blue: min(b * 1.1, 1.0),
                alpha: a)
        }
        
        // Draw stud shadow
        context.setFillColor(darkColor.cgColor)
        context.fillEllipse(
            in: CGRect(
                x: centerX - studSize * 0.6,
                y: centerY - studSize * 0.6,
                width: studSize * 1.2,
                height: studSize * 1.2))
        
        // Draw stud top
        context.setFillColor(lightColor.cgColor)
        context.fillEllipse(
            in: CGRect(
                x: centerX - studSize / 2,
                y: centerY - studSize / 2,
                width: studSize,
                height: studSize))
    }
    
    // Save processed video to photo library
    static func saveVideoToPhotoLibrary(url: URL, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(
                    false,
                    NSError(
                        domain: "VideoProcessor",
                        code: 8,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access not authorized"]))
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: url, options: nil)
            } completionHandler: { success, error in
                completion(success, error)
            }
        }
    }
}
