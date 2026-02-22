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
                            ForEach(vm.sortedTemplates) { template in
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
                SortMenuButton(sortBy: $vm.sortBy, ascending: $vm.sortAscending)
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
                Button(action: {}) {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear { vm.loadSampleData() }
    }
}
