import SwiftUI

/// Pod detail panel with tabs
struct PodDetailView: View {
    let pod: PodViewModel?
    @Binding var activeTab: PodDetailTab

    var body: some View {
        VStack(spacing: 0) {
            // Detail toolbar
            HStack {
                Picker("Tab", selection: $activeTab) {
                    ForEach(PodDetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 250)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider()

            if let pod {
                switch activeTab {
                case .info:
                    ScrollView {
                        VStack(spacing: 0) {
                            InfoRow(label: "Name", value: pod.name)
                            InfoRow(label: "Namespace", value: pod.namespace)
                            InfoRow(label: "Phase", value: pod.phase.rawValue)
                            InfoRow(label: "Ready", value: pod.readyDisplay)
                            InfoRow(label: "Restarts", value: "\(pod.restartCount)")
                            InfoRow(label: "Created", value: pod.createdAgo)
                        }
                        .padding(16)
                    }
                case .logs:
                    Spacer()
                    Text("Logs coming soon...")
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                case .terminal:
                    Spacer()
                    Text("Terminal coming soon...")
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
