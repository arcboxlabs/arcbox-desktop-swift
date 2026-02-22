import SwiftUI

/// Sort menu button for toolbar usage
struct SortMenuButton: View {
    var body: some View {
        Menu {
            Button("Name") { }
            Button("Date Created") { }
            Button("Size") { }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
}
