import SwiftUI
import ArcBoxClient

/// Center panel: list header + container rows + detail panel
struct ContainersListView: View {
    @State private var vm = ContainersViewModel()
    @Environment(\.arcboxClient) private var client

    var body: some View {
        HStack(spacing: 0) {
            // Left: list panel
            VStack(spacing: 0) {
                // Container list or empty state
                if vm.containers.isEmpty {
                    ContainerEmptyState()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Compose groups
                            ForEach(vm.composeGroups, id: \.project) { group in
                                ContainerGroupView(
                                    project: group.project,
                                    containers: group.containers,
                                    isExpanded: vm.isGroupExpanded(group.project),
                                    selectedID: vm.selectedID,
                                    onToggle: { vm.toggleGroup(group.project) },
                                    onSelect: { vm.selectContainer($0) },
                                    onStartStop: { id, running in
                                        Task {
                                            if running { await vm.stopContainer(id, client: client) }
                                            else { await vm.startContainer(id, client: client) }
                                        }
                                    },
                                    onDelete: { id in
                                        Task { await vm.removeContainer(id, client: client) }
                                    }
                                )
                            }

                            // Standalone containers
                            ForEach(vm.standaloneContainers) { container in
                                ContainerRowView(
                                    container: container,
                                    isSelected: vm.selectedID == container.id,
                                    indented: false,
                                    onSelect: { vm.selectContainer(container.id) },
                                    onStartStop: {
                                        Task {
                                            if container.isRunning { await vm.stopContainer(container.id, client: client) }
                                            else { await vm.startContainer(container.id, client: client) }
                                        }
                                    },
                                    onDelete: {
                                        Task { await vm.removeContainer(container.id, client: client) }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .frame(width: vm.listWidth)

            // Resize handle
            ListResizeHandle(width: $vm.listWidth, min: 200, max: 500)

            // Right: detail panel
            ContainerDetailView(
                container: vm.selectedContainer,
                activeTab: $vm.activeTab
            )
        }
        .navigationTitle("Containers")
        .navigationSubtitle("\(vm.runningCount) running")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                SortMenuButton(sortBy: $vm.sortBy, ascending: $vm.sortAscending)
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: { vm.showNewContainerSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await vm.loadContainers(client: client)
        }
        .sheet(isPresented: $vm.showNewContainerSheet) {
            NewContainerSheet()
        }
    }
}
