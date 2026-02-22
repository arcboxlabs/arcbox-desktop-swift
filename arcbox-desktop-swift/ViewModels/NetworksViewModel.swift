import SwiftUI

/// Detail tab for networks
enum NetworkDetailTab: String, CaseIterable, Identifiable {
    case info = "Info"
    case containers = "Containers"

    var id: String { rawValue }
}

/// Sort field for networks
enum NetworkSortField: String, CaseIterable {
    case name = "Name"
    case dateCreated = "Date Created"
}

/// Network list state
@Observable
class NetworksViewModel {
    var networks: [NetworkViewModel] = []
    var selectedID: String? = nil
    var activeTab: NetworkDetailTab = .info
    var listWidth: CGFloat = 320
    var showNewNetworkSheet: Bool = false
    var sortBy: NetworkSortField = .name
    var sortAscending: Bool = true

    var networkCount: Int { networks.count }

    var sortedNetworks: [NetworkViewModel] {
        networks.sorted { a, b in
            let result: Bool
            switch sortBy {
            case .name:
                result = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .dateCreated:
                result = a.createdAt < b.createdAt
            }
            return sortAscending ? result : !result
        }
    }

    var selectedNetwork: NetworkViewModel? {
        guard let id = selectedID else { return nil }
        return networks.first { $0.id == id }
    }

    func selectNetwork(_ id: String) {
        selectedID = id
    }

    func loadSampleData() {
        networks = SampleData.networks
    }
}
