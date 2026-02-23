import SwiftUI
import ArcBoxClient

@main
struct ArcBoxDesktopApp: App {
    @State private var appVM = AppViewModel()
    @State private var daemonManager = DaemonManager()
    @State private var arcboxClient: ArcBoxClient?

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appVM)
                .environment(daemonManager)
                .environment(\.arcboxClient, arcboxClient)
                .frame(minWidth: 900, minHeight: 600)
                .task {
                    await daemonManager.startDaemon()
                    if daemonManager.state.isRunning {
                        do {
                            let client = try ArcBoxClient()
                            Task { try await client.runConnections() }
                            arcboxClient = client
                        } catch {}
                    }
                }
        }
        .defaultSize(width: 1200, height: 800)
    }
}

// MARK: - Environment Key

private struct ArcBoxClientKey: EnvironmentKey {
    static let defaultValue: ArcBoxClient? = nil
}

extension EnvironmentValues {
    var arcboxClient: ArcBoxClient? {
        get { self[ArcBoxClientKey.self] }
        set { self[ArcBoxClientKey.self] = newValue }
    }
}
