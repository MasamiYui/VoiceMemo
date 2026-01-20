import XCTest
@testable import WeChatVoiceRecorder

final class TingwuCreateTaskTests: XCTestCase {
    private let accessKeyId = "YOUR_ACCESS_KEY_ID"
    private let accessKeySecret = "YOUR_ACCESS_KEY_SECRET"
    private let appKey = "YOUR_TINGWU_APPKEY"
    private let fileUrl = "YOUR_PUBLIC_OSS_FILE_URL"
    
    func testCreateTask() async throws {
        guard !accessKeyId.isEmpty, accessKeyId != "YOUR_ACCESS_KEY_ID",
              !accessKeySecret.isEmpty, accessKeySecret != "YOUR_ACCESS_KEY_SECRET",
              !appKey.isEmpty, appKey != "YOUR_TINGWU_APPKEY",
              !fileUrl.isEmpty, fileUrl != "YOUR_PUBLIC_OSS_FILE_URL" else {
            throw XCTSkip("Please fill Tingwu credentials and OSS file URL in TingwuCreateTaskTests.swift")
        }
        
        let settings = SettingsStore()
        settings.tingwuAppKey = appKey
        settings.saveAccessKeyId(accessKeyId)
        settings.saveAccessKeySecret(accessKeySecret)
        
        defer {
            settings.clearSecrets()
        }
        
        let service = TingwuService(settings: settings)
        let taskId = try await service.createTask(fileUrl: fileUrl)
        
        XCTAssertFalse(taskId.isEmpty)
    }
}
