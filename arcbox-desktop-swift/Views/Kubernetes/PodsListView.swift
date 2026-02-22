import SwiftUI

/// Pods list + detail panel
struct PodsListView: View {
    @State private var vm = PodsViewModel()

    var body: some View {
        HStack(spacing: 0) {
            // Left: list panel
            VStack(spacing: 0) {
                if !vm.kubernetesEnabled {
                    KubernetesDisabledView()
                } else if vm.pods.isEmpty {
                    VStack {
                        Spacer()
                        Text("No pods")
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.pods) { pod in
                                PodRowView(
                                    pod: pod,
                                    isSelected: vm.selectedID == pod.id,
                                    onSelect: { vm.selectPod(pod.id) }
                                )
                            }
                        }
                    }
                }
            }
            .frame(width: vm.listWidth)

            ListResizeHandle(width: $vm.listWidth, min: 200, max: 500)

            // Right: detail panel
            PodDetailView(
                pod: vm.selectedPod,
                activeTab: $vm.activeTab
            )
        }
        .navigationTitle("Pods")
        .navigationSubtitle(vm.kubernetesEnabled ? "\(vm.podCount) total" : "Disabled")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                IconButton(symbol: "magnifyingglass") {}
            }
        }
        .onAppear { vm.loadSampleData() }
    }
}
