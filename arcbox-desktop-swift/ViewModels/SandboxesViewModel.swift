import SwiftUI

/// Detail tab for sandboxes
enum SandboxDetailTab: String, CaseIterable, Identifiable {
    case info = "Info"
    case logs = "Logs"

    var id: String { rawValue }
}

/// Top-level tab for sandboxes page
enum SandboxPageTab: String, CaseIterable, Identifiable {
    case monitoring = "Monitoring"
    case list = "List"

    var id: String { rawValue }
}

/// Sandbox list state
@Observable
class SandboxesViewModel {
    var sandboxes: [SandboxViewModel] = []
    var selectedID: String? = nil
    var activeTab: SandboxDetailTab = .info
    var pageTab: SandboxPageTab = .monitoring
    var listWidth: CGFloat = 320

    // Monitoring metrics
    var concurrentSandboxes: Int = 0
    var startRatePerSecond: Double = 0.0
    var peakConcurrentSandboxes: Int = 1
    var concurrentLimit: Int = 20

    var sandboxCount: Int { sandboxes.count }

    var selectedSandbox: SandboxViewModel? {
        guard let id = selectedID else { return nil }
        return sandboxes.first { $0.id == id }
    }

    func selectSandbox(_ id: String) {
        selectedID = id
    }

    func loadSampleData() {
        sandboxes = SampleData.sandboxes
        concurrentSandboxes = sandboxes.filter { $0.isRunning }.count
    }
}
