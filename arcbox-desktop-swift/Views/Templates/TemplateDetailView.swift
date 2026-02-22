import SwiftUI

/// Template detail panel with tabs
struct TemplateDetailView: View {
    let template: TemplateViewModel?
    @Binding var activeTab: TemplateDetailTab

    var body: some View {
        VStack(spacing: 0) {
            // Detail toolbar
            HStack {
                Picker("Tab", selection: $activeTab) {
                    ForEach(TemplateDetailTab.allCases) { tab in
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

            if let template {
                switch activeTab {
                case .info:
                    ScrollView {
                        VStack(spacing: 0) {
                            InfoRow(label: "Name", value: template.name)
                            InfoRow(label: "ID", value: template.shortID)
                            InfoRow(label: "CPU", value: template.cpuDisplay)
                            InfoRow(label: "Memory", value: template.memoryDisplay)
                            InfoRow(label: "Created", value: template.createdAgo)
                            InfoRow(label: "Updated", value: template.updatedAgo)
                            InfoRow(label: "Sandboxes", value: template.sandboxCountDisplay)
                        }
                        .padding(16)
                    }
                case .sandboxes:
                    Spacer()
                    Text("Sandboxes coming soon...")
                        .foregroundStyle(AppColors.textSecondary)
                    Spacer()
                }
            } else {
                Spacer()
                Text("No Selection")
                    .foregroundStyle(AppColors.textSecondary)
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}
