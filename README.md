# WeChatVoiceRecorder

A professional, high-fidelity audio recording utility for macOS, specifically designed to capture real-time WeChat voice conversations using the native **ScreenCaptureKit** and **AVFoundation** frameworks.

## Features

- **Dual-Track Recording**: Simultaneously captures system audio (remote voice) and microphone input (local voice).
- **Automatic Merging**: Intelligently mixes both tracks into a single high-quality audio file post-recording.
- **Intelligent App Detection**: Automatically filters and prioritizes WeChat for seamless capture.
- **Native Performance**: Built with SwiftUI and ScreenCaptureKit for optimal performance and low CPU overhead.
- **Privacy-First**: Operates locally on your machine with clear permission handling.

## Requirements

- **OS**: macOS 13.0 (Ventura) or later.
- **Hardware**: Any Mac supporting macOS 13.0+.
- **Development**: Xcode 14.1+ for building and signing.

## Project Structure

- `Sources/`: Core Swift implementation.
- `Package.swift`: Swift Package Manager configuration.
- `package_app.sh`: Automated build and ad-hoc signing script.
- `Info.plist`: Application configuration and permission strings.

## Getting Started

### 1. Build and Run

Due to macOS security requirements (ScreenCaptureKit needs specific entitlements and signing), we provide a convenience script for local execution:

```bash
chmod +x package_app.sh
./package_app.sh
open WeChatVoiceRecorder.app
```

### 2. Permissions

When you first start recording, macOS will request the following permissions:
- **Screen Recording**: Required by ScreenCaptureKit to capture system/app audio.
- **Microphone**: Required to capture your own voice.

Please grant these permissions in **System Settings > Privacy & Security**.

### 3. Audio Outputs

Recordings are saved to your `Downloads` directory with the following naming convention:
- `remote_[timestamp]_[id].m4a`: The other person's voice.
- `local_[timestamp]_[id].m4a`: Your voice.
- `mixed_[timestamp]_[id].m4a`: The merged conversation.

## Development

To open the project in Xcode for debugging:

```bash
xed .
```

Ensure you configure **Signing & Capabilities** with your Development Team to run the app with full permissions.

## Roadmap

- [x] Dual-track recording (Remote + Local)
- [x] Automatic audio merging
- [ ] Alibaba Cloud ASR integration for speech-to-text
- [ ] Speaker diarization (Cloud-based)
- [ ] Real-time transcription UI

## License

[MIT License](LICENSE)
