import Foundation
import TypeWhisperPluginSDK

// Local-build stub. The real engine uses Apple's macOS 26 `SpeechAnalyzer` / `SpeechTranscriber`
// API, whose symbols are absent from this build's SDK (Xcode 16.4 / macOS 15 SDK), so the original
// implementation cannot compile here. This stub conforms only to the base plugin protocol, so the
// bundle loads cleanly but registers no transcription engine — TypeWhisper uses the other engines
// (Parakeet, WhisperKit, …) exactly as before. Original preserved at SpeechAnalyzerPlugin.swift.orig.
@objc(SpeechAnalyzerPlugin)
final class SpeechAnalyzerPlugin: NSObject, TypeWhisperPlugin, @unchecked Sendable {
    static let pluginId = "com.typewhisper.speechanalyzer"
    static let pluginName = "Apple Speech"

    required override init() { super.init() }
    func activate(host: HostServices) {}
    func deactivate() {}
}
