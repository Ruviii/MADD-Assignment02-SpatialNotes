
import SwiftUI

@main
struct SpatialNotesApp: App {

    @State private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(
            selection: Binding(
                get: { appModel.immersionStyle },
                set: { newStyle in
                    // Update selection when system changes immersion style
                    // Check if it matches our current selection's style
                    _ = appModel.immersionStyleSelection.immersionStyle
                    // Since we can't directly compare protocol types, we rely on
                    // the picker to update immersionStyleSelection, and this binding
                    // just provides the current value to the system
                    // The setter is called by the system but we don't need to act on it
                    // since the user controls it via the picker
                }
            ),
            in: .mixed,
            .progressive
        )
        .onChange(of: appModel.immersionStyleSelection) { oldValue, newValue in
            // When user changes selection via picker, the immersion style is automatically
            // updated through the computed property, which the binding will read
        }
     }
}
