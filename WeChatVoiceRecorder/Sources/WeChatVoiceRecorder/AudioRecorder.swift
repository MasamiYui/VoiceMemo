import Foundation
import ScreenCaptureKit
import AVFoundation
import AppKit

@available(macOS 13.0, *)
class AudioRecorder: NSObject, ObservableObject, SCStreamOutput, SCStreamDelegate {
    @Published var isRecording = false
    @Published var statusMessage = "Ready to record"
    @Published var availableApps: [SCRunningApplication] = []
    @Published var selectedApp: SCRunningApplication?
    
    private var stream: SCStream?
    private var assetWriter: AVAssetWriter?
    private var assetWriterInput: AVAssetWriterInput?
    private let audioQueue = DispatchQueue(label: "com.wechatvoicerecorder.audio")
    private var isFirstBuffer = true
    
    override init() {
        super.init()
        Task {
            await refreshAvailableApps()
        }
    }
    
    @MainActor
    func refreshAvailableApps() async {
        do {
            let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            self.availableApps = content.applications.sorted { $0.applicationName < $1.applicationName }
            
            if let wechat = self.availableApps.first(where: { $0.applicationName.lowercased().contains("wechat") || $0.applicationName.contains("微信") }) {
                self.selectedApp = wechat
                self.statusMessage = "Auto-selected: \(wechat.applicationName)"
            }
        } catch {
            self.statusMessage = "Failed to load apps: \(error.localizedDescription)"
        }
    }
    
    func startRecording() {
        guard let app = selectedApp else {
            statusMessage = "Please select an app first"
            return
        }
        
        statusMessage = "Starting capture for \(app.applicationName)..."
        isFirstBuffer = true
        
        Task {
            do {
                let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                guard let matchedApp = content.applications.first(where: { $0.processID == app.processID }) else {
                    await MainActor.run { statusMessage = "App not found running" }
                    return
                }
                
                let filter = SCContentFilter(display: content.displays.first!, including: [matchedApp], exceptingWindows: [])
                let config = SCStreamConfiguration()
                
                config.capturesAudio = true
                config.sampleRate = 48000
                config.channelCount = 2
                config.excludesCurrentProcessAudio = true
                
                // ScreenCaptureKit in macOS 13 uses width/height to determine if video is captured.
                // For audio-only, we can set them to 0 or small values, but the key is capturesAudio.
                config.width = 2
                config.height = 2
                
                stream = SCStream(filter: filter, configuration: config, delegate: self)
                try stream?.addStreamOutput(self, type: .audio, sampleHandlerQueue: audioQueue)
                try await stream?.startCapture()
                
                await MainActor.run {
                    self.isRecording = true
                    self.statusMessage = "Recording \(app.applicationName)..."
                }
                
            } catch {
                await MainActor.run {
                    self.statusMessage = "Error starting capture: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func stopRecording() {
        Task {
            do {
                try await stream?.stopCapture()
                stream = nil
                
                if let writer = assetWriter, writer.status == .writing {
                    assetWriterInput?.markAsFinished()
                    await writer.finishWriting()
                }
                assetWriter = nil
                assetWriterInput = nil
                
                await MainActor.run {
                    self.isRecording = false
                    self.statusMessage = "Recording saved to Downloads/WeChatRecordings"
                }
            } catch {
                await MainActor.run {
                    self.statusMessage = "Error stopping: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func setupAssetWriter(for sampleBuffer: CMSampleBuffer) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
              let streamBasicDescription = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) else {
            return
        }
        
        let fileManager = FileManager.default
        let downloads = fileManager.urls(for: .downloadsDirectory, in: .userDomainMask).first!
        let folder = downloads.appendingPathComponent("WeChatRecordings")
        try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let url = folder.appendingPathComponent("recording-\(formatter.string(from: Date())).m4a")
        
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: .m4a)
            
            let settings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: streamBasicDescription.pointee.mSampleRate,
                AVNumberOfChannelsKey: streamBasicDescription.pointee.mChannelsPerFrame,
                AVEncoderBitRateKey: 128000
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: .audio, outputSettings: settings)
            assetWriterInput?.expectsMediaDataInRealTime = true
            
            if let writer = assetWriter, let input = assetWriterInput, writer.canAdd(input) {
                writer.add(input)
                writer.startWriting()
            }
        } catch {
            print("AssetWriter setup failed: \(error)")
        }
    }
    
    // MARK: - SCStreamOutput
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio, CMSampleBufferDataIsReady(sampleBuffer) else { return }
        
        if isFirstBuffer {
            setupAssetWriter(for: sampleBuffer)
            assetWriter?.startSession(atSourceTime: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
            isFirstBuffer = false
        }
        
        if let input = assetWriterInput, input.isReadyForMoreMediaData {
            input.append(sampleBuffer)
        }
    }
    
    func stream(_ stream: SCStream, didStopWithError error: Error) {
        Task {
            await MainActor.run {
                self.isRecording = false
                self.statusMessage = "Stream stopped: \(error.localizedDescription)"
            }
        }
    }
}
