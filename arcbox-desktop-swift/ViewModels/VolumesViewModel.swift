import SwiftUI

/// Detail tab for volumes
enum VolumeDetailTab: String, CaseIterable, Identifiable {
    case info = "Info"
    case files = "Files"

    var id: String { rawValue }
}

/// Sort field for volumes
enum VolumeSortField: String, CaseIterable {
    case name = "Name"
    case dateCreated = "Date Created"
    case size = "Size"
}

/// Volume list state
@Observable
class VolumesViewModel {
    var volumes: [VolumeViewModel] = []
    var selectedID: String? = nil
    var activeTab: VolumeDetailTab = .info
    var listWidth: CGFloat = 320
    var showNewVolumeSheet: Bool = false
    var sortBy: VolumeSortField = .name
    var sortAscending: Bool = true

    var totalSize: String {
        let bytes: UInt64 = volumes.compactMap(\.sizeBytes).reduce(0, +)
        let gb = Double(bytes) / 1_000_000_000.0
        if gb >= 1.0 {
            return String(format: "%.2f GB total", gb)
        }
        let mb = Double(bytes) / 1_000_000.0
        return String(format: "%.0f MB total", mb)
    }

    var sortedVolumes: [VolumeViewModel] {
        volumes.sorted { a, b in
            let result: Bool
            switch sortBy {
            case .name:
                result = a.name.localizedCaseInsensitiveCompare(b.name) == .orderedAscending
            case .dateCreated:
                result = a.createdAt < b.createdAt
            case .size:
                result = (a.sizeBytes ?? 0) < (b.sizeBytes ?? 0)
            }
            return sortAscending ? result : !result
        }
    }

    var selectedVolume: VolumeViewModel? {
        guard let id = selectedID else { return nil }
        return volumes.first { $0.id == id }
    }

    func selectVolume(_ id: String) {
        selectedID = id
    }

    func loadSampleData() {
        volumes = SampleData.volumes
    }
}
