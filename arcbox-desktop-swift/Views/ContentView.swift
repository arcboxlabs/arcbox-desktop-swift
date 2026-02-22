import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) private var appVM

    var body: some View {
        @Bindable var vm = appVM

        NavigationSplitView {
            List(selection: $vm.currentNav) {
                Section("Docker") {
                    ForEach(NavItem.Section.docker.items) { item in
                        Label(item.label, systemImage: item.sfSymbol)
                            .tag(item)
                    }
                }
                Section("Kubernetes") {
                    ForEach(NavItem.Section.kubernetes.items) { item in
                        Label(item.label, systemImage: item.sfSymbol)
                            .tag(item)
                    }
                }
                Section("Linux") {
                    ForEach(NavItem.Section.linux.items) { item in
                        Label(item.label, systemImage: item.sfSymbol)
                            .tag(item)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 150, ideal: 180, max: 220)
        } detail: {
            switch vm.currentNav {
            case .containers:
                ContainersListView()
            case .volumes:
                VolumesListView()
            case .images:
                ImagesListView()
            case .networks:
                NetworksListView()
            case .pods:
                PodsListView()
            case .services:
                ServicesListView()
            case .machines:
                MachinesView()
            case nil:
                ContainersListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppViewModel())
}
