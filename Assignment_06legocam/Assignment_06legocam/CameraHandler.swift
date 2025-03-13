import AVFoundation
import UIKit
import SwiftUI
import Combine

class CameraHandler: NSObject, ObservableObject {
    // Published properties for the view to observe
    @Published var viewfinderImage: UIImage?
    @Published var legoImage: UIImage?
    @Published var isRecording = false
    
    // Camera session
    private let captureSession = AVCaptureSession()
    private var videoOutput = AVCaptureVideoDataOutput()
    private var movieOutput = AVCaptureMovieFileOutput()
    
    // Settings
    private(set) var legoSize = 20
    
    // Queue for processing video
    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInitiated)
    
    // Current recording URL
    private var recordingURL: URL?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        // Check camera authorization
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.setupCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.beginConfiguration()
        
        // Add inputs
        captureSession.addInput(videoInput)
        
        // Set up video output for processing
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Set up movie output for recording
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        captureSession.commitConfiguration()
        
        // Start session in background
        videoQueue.async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    // Update LEGO size
    func increaseLegoSize() {
        legoSize = min(legoSize + 5, 40)
    }
    
    func decreaseLegoSize() {
        legoSize = max(legoSize - 5, 10)
    }
    
    // Take photo
    func takePhoto() {
        // Capture current LEGO effect image and save to photos
        guard let legoImage = legoImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(legoImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving photo: \(error.localizedDescription)")
        } else {
            print("Photo saved successfully")
        }
    }
    
    // Start recording
    func startRecording() {
        guard !movieOutput.isRecording else { return }
        
        // Create temporary file URL
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "LegoVideo_\(Date().timeIntervalSince1970).mov"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        recordingURL = fileURL
        movieOutput.startRecording(to: fileURL, recordingDelegate: self)
        isRecording = true
    }
    
    // Stop recording
    func stopRecording() {
        guard movieOutput.isRecording else { return }
        movieOutput.stopRecording()
        isRecording = false
    }
    
    // Apply LEGO effect
    private func applyLegoEffect(to image: UIImage) -> UIImage? {
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
                drawLegoBrick(in: context, at: CGPoint(x: x, y: y), size: legoSize, color: UIColor(red: red, green: green, blue: blue, alpha: 1.0))
            }
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func drawLegoBrick(in context: CGContext, at point: CGPoint, size: Int, color: UIColor) {
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
            lightColor = UIColor(red: min(r * 1.1, 1.0), green: min(g * 1.1, 1.0), blue: min(b * 1.1, 1.0), alpha: a)
        }
        
        // Draw stud shadow
        context.setFillColor(darkColor.cgColor)
        context.fillEllipse(in: CGRect(x: centerX - studSize * 0.6, y: centerY - studSize * 0.6, width: studSize * 1.2, height: studSize * 1.2))
        
        // Draw stud top
        context.setFillColor(lightColor.cgColor)
        context.fillEllipse(in: CGRect(x: centerX - studSize / 2, y: centerY - studSize / 2, width: studSize, height: studSize))
    }
}

// MARK: - Video processing delegate
extension CameraHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Convert CIImage to UIImage
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let image = UIImage(cgImage: cgImage)
        
        // Update viewfinder with original image
        DispatchQueue.main.async {
            self.viewfinderImage = image
        }
        
        // Apply LEGO effect
        if let legoImage = applyLegoEffect(to: image) {
            DispatchQueue.main.async {
                self.legoImage = legoImage
            }
        }
    }
}

// MARK: - Movie recording delegate
extension CameraHandler: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Recording started
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // Process recorded video with LEGO effect
        if let url = recordingURL {
            applyLegoEffectToVideo(at: url)
        }
    }
    
    private func applyLegoEffectToVideo(at url: URL) {
        // Process video with LEGO effect
        VideoProcessor.processVideo(inputURL: url, legoSize: legoSize) { result in
            switch result {
            case .success(let processedURL):
                // Save processed video to photo library
                VideoProcessor.saveVideoToPhotoLibrary(url: processedURL) { success, error in
                    if success {
                        print("LEGO video saved to library")
                    } else if let error = error {
                        print("Error saving LEGO video: \(error.localizedDescription)")
                    }
                }
            case .failure(let error):
                print("Error processing video: \(error.localizedDescription)")
            }
        }
    }
}
