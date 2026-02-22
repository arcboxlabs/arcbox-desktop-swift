import SwiftUI

/// Detail tab for templates
enum TemplateDetailTab: String, CaseIterable, Identifiable {
    case info = "Info"
    case sandboxes = "Sandboxes"

    var id: String { rawValue }
}

/// Template list state
@Observable
class TemplatesViewModel {
    var templates: [TemplateViewModel] = []
    var selectedID: String? = nil
    var activeTab: TemplateDetailTab = .info
    var listWidth: CGFloat = 320

    var templateCount: Int { templates.count }

    var selectedTemplate: TemplateViewModel? {
        guard let id = selectedID else { return nil }
        return templates.first { $0.id == id }
    }

    func selectTemplate(_ id: String) {
        selectedID = id
    }

    func loadSampleData() {
        templates = SampleData.templates
    }
}
