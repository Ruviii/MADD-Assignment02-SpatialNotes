import SwiftUI

/// Toolbar with spawn button for creating new notes
struct ToolbarView: View {
    // MARK: - Properties
    
    @Environment(AppModel.self) private var appModel
    let onSpawnNote: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        HStack {
            Button {
                onSpawnNote()
            } label: {
                Label("Spawn in front", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            
            if appModel.immersiveSpaceState != .open {
                Text("(Open Immersive Space first)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ToolbarView(onSpawnNote: {})
        .environment(AppModel())
}

