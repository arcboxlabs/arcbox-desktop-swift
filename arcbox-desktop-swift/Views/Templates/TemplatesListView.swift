import SwiftUI

/// Templates list + detail panel
struct TemplatesListView: View {
    @State private var vm = TemplatesViewModel()

    var body: some View {
        HStack(spacing: 0) {
            // Left: list panel
            VStack(spacing: 0) {
                if vm.templates.isEmpty {
                    TemplateEmptyState()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.templates) { template in
                                TemplateRowView(
                                    template: template,
                                    isSelected: vm.selectedID == template.id,
                                    onSelect: { vm.selectTemplate(template.id) }
                                )
                            }
                        }
                    }
                }
            }
            .frame(width: vm.listWidth)

            ListResizeHandle(width: $vm.listWidth, min: 200, max: 500)

            // Right: detail panel
            TemplateDetailView(
                template: vm.selectedTemplate,
                activeTab: $vm.activeTab
            )
        }
        .navigationTitle("Templates")
        .navigationSubtitle("\(vm.templateCount) total")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                SortMenuButton()
                IconButton(symbol: "magnifyingglass") {}
                IconButton(symbol: "plus") {}
            }
        }
        .onAppear { vm.loadSampleData() }
    }
}
