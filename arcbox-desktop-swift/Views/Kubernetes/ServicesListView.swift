import SwiftUI

/// Services list + detail panel
struct ServicesListView: View {
    @State private var vm = ServicesViewModel()

    var body: some View {
        HStack(spacing: 0) {
            // Left: list panel
            VStack(spacing: 0) {
                if !vm.kubernetesEnabled {
                    KubernetesDisabledView()
                } else if vm.services.isEmpty {
                    VStack {
                        Spacer()
                        Text("No services")
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.services) { service in
                                ServiceRowView(
                                    service: service,
                                    isSelected: vm.selectedID == service.id,
                                    onSelect: { vm.selectService(service.id) }
                                )
                            }
                        }
                    }
                }
            }
            .frame(width: vm.listWidth)

            ListResizeHandle(width: $vm.listWidth, min: 200, max: 500)

            // Right: detail panel
            ServiceDetailView(
                service: vm.selectedService,
                activeTab: $vm.activeTab
            )
        }
        .navigationTitle("Services")
        .navigationSubtitle(vm.kubernetesEnabled ? "\(vm.serviceCount) total" : "Disabled")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
        .onAppear { vm.loadSampleData() }
    }
}
