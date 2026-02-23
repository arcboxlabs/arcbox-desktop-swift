import SwiftUI

/// Sandbox detail panel with tabs
struct SandboxDetailView: View {
    let sandbox: SandboxViewModel?
    @Binding var activeTab: SandboxDetailTab

    private func stateColor(_ state: SandboxState) -> Color {
        switch state {
        case .running: AppColors.running
        case .paused: AppColors.warning
        case .stopped: AppColors.stopped
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Detail toolbar
            HStack {
                Picker("Tab", selection: $activeTab) {
                    ForEach(SandboxDetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 200)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider()

            if let sandbox {
                switch activeTab {
                case .info:
                    ScrollView {
                        VStack(spacing: 0) {
                            InfoRow(label: "Alias", value: sandbox.alias)
                            InfoRow(label: "ID", value: sandbox.shortID)
                            InfoRow(label: "Template", value: sandbox.templateID)
                            InfoRow(label: "Status", value: sandbox.state.label)
                            InfoRow(label: "CPU", value: sandbox.cpuDisplay)
                            InfoRow(label: "Memory", value: sandbox.memoryDisplay)
                            InfoRow(label: "Started", value: sandbox.startedAgo)
                            InfoRow(label: "Time Left", value: sandbox.timeRemaining)
                        }
                        .padding(16)
                    }
                case .logs:
                    Spacer()
                    Text("Logs coming soon...")
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
            } else {
                Spacer()
                Text("No Selection")
                    .foregroundStyle(AppColors.textSecondary)
                    .font(.system(size: 15))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
