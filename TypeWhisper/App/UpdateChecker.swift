@preconcurrency import Sparkle

struct UpdateChecker: Sendable {
    let canCheckForUpdates: @Sendable () -> Bool
    let checkForUpdates: @Sendable () -> Void
    let resetUpdateCycleAfterSettingsChange: @Sendable () -> Void

    static func sparkle(_ updater: SPUUpdater) -> UpdateChecker {
        nonisolated(unsafe) let updater = updater
        return UpdateChecker(
            canCheckForUpdates: { MainActor.assumeIsolated { updater.canCheckForUpdates } },
            checkForUpdates: { MainActor.assumeIsolated { updater.checkForUpdates() } },
            resetUpdateCycleAfterSettingsChange: { MainActor.assumeIsolated { updater.resetUpdateCycleAfterShortDelay() } }
        )
    }

    nonisolated(unsafe) static var shared: UpdateChecker?
}
