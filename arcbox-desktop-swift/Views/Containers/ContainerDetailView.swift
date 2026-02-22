import SwiftUI

/// Right panel: tab-based detail view
struct ContainerDetailView: View {
    let container: ContainerViewModel?
    @Binding var activeTab: ContainerDetailTab

    var body: some View {
        VStack(spacing: 0) {
            // Detail toolbar
            HStack {
                Picker("Tab", selection: $activeTab) {
                    ForEach(ContainerDetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 300)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider()

            if let container {
                switch activeTab {
                case .info:
                    ContainerInfoTab(container: container)
                case .logs:
                    ContainerLogsTab()
                case .terminal:
                    ContainerTerminalTab()
                case .files:
                    ContainerFilesTab()
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
