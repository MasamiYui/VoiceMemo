import SwiftUI
import ScreenCaptureKit

struct RecordingView: View {
    @ObservedObject var recorder: AudioRecorder
    @ObservedObject var settings: SettingsStore
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header & Status
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("New Recording")
                            .font(.system(size: 28, weight: .bold))
                        
                        Spacer()
                        
                        // Compact Status Indicator
                        HStack(spacing: 6) {
                            Circle()
                                .fill(recorder.isRecording ? Color.red : Color.gray)
                                .frame(width: 8, height: 8)
                            Text(recorder.statusMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Capsule().fill(Color(nsColor: .controlBackgroundColor)))
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Configuration Card
                VStack(spacing: 20) {
                    // App Selection Row
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Target Application")
                                .font(.headline)
                            Spacer()
                            Button(action: {
                                Task { await recorder.refreshAvailableApps() }
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 12))
                            }
                            .buttonStyle(.plain)
                            .help("Refresh App List")
                            .disabled(recorder.isRecording)
                        }
                        
                        Picker("Select App to Record:", selection: $recorder.selectedApp) {
                            Text("Select an App").tag(nil as SCRunningApplication?)
                            ForEach(recorder.availableApps, id: \.processID) { app in
                                Text(app.applicationName).tag(app as SCRunningApplication?)
                            }
                        }
                        .labelsHidden()
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()

                    // Mode Selection Row
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recognition Mode")
                            .font(.headline)
                        
                        Picker("Recognition Mode", selection: $recorder.recordingMode) {
                            Text("Mixed (Default)").tag(MeetingMode.mixed)
                            Text("Dual-Speaker Separated").tag(MeetingMode.separated)
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                        
                        // Description area
                        ZStack(alignment: .topLeading) {
                            if recorder.recordingMode == .separated {
                                Text("Separated mode treats System Audio as Speaker 2 (Remote) and Microphone as Speaker 1 (Local). They will be recognized independently.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .transition(.opacity)
                            } else {
                                Text("Mixed mode combines all audio sources into a single track for recognition. Suitable for general recordings and single-speaker scenarios.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .transition(.opacity)
                            }
                        }
                        .frame(minHeight: 32, alignment: .topLeading)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(nsColor: .windowBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                )
                .padding(.horizontal)
                .disabled(recorder.isRecording)

                // Action Controls
                HStack(spacing: 16) {
                    if !recorder.isRecording {
                        Button(action: {
                            recorder.startRecording()
                        }) {
                            HStack {
                                Image(systemName: "record.circle.fill")
                                Text("Start Recording")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .disabled(recorder.selectedApp == nil)
                        .keyboardShortcut("R", modifiers: .command)
                    } else {
                        Button(action: {
                            recorder.stopRecording()
                        }) {
                            HStack {
                                Image(systemName: "stop.circle.fill")
                                Text("Stop Recording")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primary)
                        .keyboardShortcut(".", modifiers: .command)
                    }
                }
                .padding(.horizontal)

                // Latest Task Pipeline Section
                if let task = recorder.latestTask {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Latest Task Processing")
                                .font(.headline)
                            Spacer()
                            StatusBadge(status: task.status)
                        }
                        .padding(.horizontal)
                        
                        PipelineView(task: task, settings: settings)
                            .id(task.id)
                            .padding(.bottom)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 20)
            }
            .animation(.default, value: recorder.isRecording)
            .animation(.default, value: recorder.recordingMode)
            .animation(.default, value: recorder.latestTask?.id)
        }
    }
}
