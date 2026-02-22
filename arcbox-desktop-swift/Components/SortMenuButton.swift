import SwiftUI

/// Generic sort menu button for toolbar usage
struct SortMenuButton<Field: Hashable & CaseIterable & RawRepresentable>: View
    where Field.RawValue == String, Field.AllCases: RandomAccessCollection
{
    @Binding var sortBy: Field
    @Binding var ascending: Bool

    var body: some View {
        Menu {
            Picker("Sort By", selection: $sortBy) {
                ForEach(Field.allCases, id: \.self) { field in
                    Text(field.rawValue).tag(field)
                }
            }
            Divider()
            Picker("Order", selection: $ascending) {
                Label("Ascending", systemImage: "arrow.up").tag(true)
                Label("Descending", systemImage: "arrow.down").tag(false)
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
}
