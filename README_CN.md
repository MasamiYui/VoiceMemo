# WeChatVoiceRecorder (微信语音录制器)

一款专业、高保真的 macOS 音频录制工具，专为捕获微信实时语音通话设计。基于 macOS 原生的 **ScreenCaptureKit** 和 **AVFoundation** 框架构建。

## 功能特性

- **双轨录制**：同时捕获系统音频（对方声音）和麦克风输入（自己的声音）。
- **自动合成**：录音结束后，智能地将两个轨道合并为一个高质量的混音文件。
- **智能应用检测**：自动过滤并优先识别微信应用，实现无缝捕获。
- **原生性能**：采用 SwiftUI 和 ScreenCaptureKit 开发，性能卓越，CPU 占用率极低。
- **隐私优先**：所有处理均在本地完成，具有清晰的权限管理机制。

## 环境要求

- **操作系统**：macOS 13.0 (Ventura) 或更高版本。
- **硬件**：任何支持 macOS 13.0+ 的 Mac 设备。
- **开发工具**：Xcode 14.1+（用于编译和签名）。

## 项目结构

- `Sources/`：核心 Swift 代码实现。
- `Package.swift`：Swift Package Manager 项目配置。
- `package_app.sh`：自动化编译及 Ad-hoc 签名脚本。
- `Info.plist`：应用配置及权限描述。

## 快速开始

### 1. 编译与运行

由于 macOS 的安全机制（ScreenCaptureKit 需要特定的权限和签名），我们提供了一个便捷脚本用于本地执行：

```bash
chmod +x package_app.sh
./package_app.sh
open WeChatVoiceRecorder.app
```

### 2. 权限说明

首次开始录制时，macOS 会请求以下权限：
- **屏幕录制**：ScreenCaptureKit 捕获系统/应用音频所需。
- **麦克风**：捕获您自己声音所需。

请在 **系统设置 > 隐私与安全性** 中授予这些权限。

### 3. 音频输出

录音文件将保存至您的 `下载 (Downloads)` 目录，命名规则如下：
- `remote_[时间戳]_[ID].m4a`：对方的声音。
- `local_[时间戳]_[ID].m4a`：您的声音。
- `mixed_[时间戳]_[ID].m4a`：合成后的对话内容。

## 开发与调试

若要在 Xcode 中打开项目进行调试：

```bash
xed .
```

请务必在 **Signing & Capabilities** 中配置您的开发团队（Team），以便应用能以完整权限运行。

## 开发路线图

- [x] 双轨录制 (对方 + 自己)
- [x] 自动音频合成
- [ ] 集成阿里云 ASR 实现语音转文字
- [ ] 说话人识别 (基于云端方案)
- [ ] 实时转写 UI 界面

## 开源协议

[MIT License](LICENSE)
