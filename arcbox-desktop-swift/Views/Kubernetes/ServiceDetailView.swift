import SwiftUI

/// Service detail panel
struct ServiceDetailView: View {
    let service: ServiceViewModel?
    @Binding var activeTab: ServiceDetailTab

    var body: some View {
        VStack(spacing: 0) {
            // Detail toolbar
            HStack {
                Picker("Tab", selection: $activeTab) {
                    ForEach(ServiceDetailTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(maxWidth: 120)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            Divider()

            if let service {
                switch activeTab {
                case .info:
                    ScrollView {
                        VStack(spacing: 0) {
                            InfoRow(label: "Name", value: service.name)
                            InfoRow(label: "Namespace", value: service.namespace)
                            InfoRow(label: "Type", value: service.type.rawValue)
                            InfoRow(label: "Cluster IP", value: service.clusterIP ?? "None")
                            InfoRow(label: "Ports", value: service.portsDisplay.isEmpty ? "None" : service.portsDisplay)
                            InfoRow(label: "Created", value: service.createdAgo)
                        }
                        .padding(16)
                    }
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
