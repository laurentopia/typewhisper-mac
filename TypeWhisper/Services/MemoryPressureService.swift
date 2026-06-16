import Foundation
import os.log

/// Watches the system memory-pressure signal and runs a callback when the OS reports it is low on
/// memory.
///
/// TypeWhisper uses this to shed resident local ASR models (Parakeet, WhisperKit, …), each of which
/// holds a 0.6–2 GB model in RAM. The app previously never responded to memory pressure, so an idle
/// dictation app could keep several gigabytes resident while the rest of the system thrashed.
/// Released models reload transparently on the next dictation, so this only trades a one-off reload
/// for reclaimed RAM exactly when the system needs it.
@MainActor
final class MemoryPressureService {
    enum Level: Sendable {
        case warning
        case critical
    }

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TypeWhisper",
        category: "MemoryPressure"
    )
    private var source: DispatchSourceMemoryPressure?
    private let onLevel: @Sendable (Level) -> Void

    /// - Parameter onLevel: Invoked on the main queue whenever the system reports memory pressure.
    init(onLevel: @escaping @Sendable (Level) -> Void) {
        self.onLevel = onLevel
    }

    func start() {
        guard source == nil else { return }
        let src = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
        // Capture only Sendable values (the source, the callback, the logger) so the @Sendable
        // event handler stays free of self / non-Sendable state under strict concurrency.
        let onLevel = self.onLevel
        let logger = self.logger
        src.setEventHandler { [src] in
            let level: Level = src.data.contains(.critical) ? .critical : .warning
            logger.notice(
                "System memory pressure: \(level == .critical ? "critical" : "warning", privacy: .public)"
            )
            onLevel(level)
        }
        source = src
        src.resume()
    }

    func stop() {
        source?.cancel()
        source = nil
    }

    deinit {
        source?.cancel()
    }
}
