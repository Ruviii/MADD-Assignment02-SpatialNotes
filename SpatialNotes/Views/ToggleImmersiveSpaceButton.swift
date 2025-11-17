//
//  ToggleImmersiveSpaceButton.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI

struct ToggleImmersiveSpaceButton: View {
    // MARK: - Properties
    
    @Environment(AppModel.self) private var appModel
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    
    // MARK: - Body
    
    var body: some View {
        Button {
            print("🔘 ToggleImmersiveSpaceButton: Button tapped, current state = \(appModel.immersiveSpaceState)")
            Task { @MainActor in
                switch appModel.immersiveSpaceState {
                    case .open:
                        print("   ➡️ Dismissing immersive space...")
                        appModel.immersiveSpaceState = .inTransition
                        await dismissImmersiveSpace()
                        // Don't set immersiveSpaceState to .closed because there
                        // are multiple paths to ImmersiveView.onDisappear().
                        // Only set .closed in ImmersiveView.onDisappear().

                    case .closed:
                        print("   ➡️ Opening immersive space...")
                        appModel.immersiveSpaceState = .inTransition
                        let result = await openImmersiveSpace(id: appModel.immersiveSpaceID)
                        print("   📬 openImmersiveSpace result: \(result)")
                        switch result {
                            case .opened:
                                print("   ✅ Immersive space opened successfully")
                                // Don't set immersiveSpaceState to .open because there
                                // may be multiple paths to ImmersiveView.onAppear().
                                // Only set .open in ImmersiveView.onAppear().
                                break

                            case .userCancelled:
                                print("   ⚠️ User cancelled immersive space")
                                appModel.immersiveSpaceState = .closed
                            case .error:
                                print("   ❌ Error opening immersive space")
                                appModel.immersiveSpaceState = .closed
                            @unknown default:
                                print("   ⚠️ Unknown response opening immersive space")
                                // On unknown response, assume space did not open.
                                appModel.immersiveSpaceState = .closed
                        }

                    case .inTransition:
                        // This case should not ever happen because button is disabled for this case.
                        break
                }
            }
        } label: {
            Text(appModel.immersiveSpaceState == .open ? "Hide Immersive Space" : "Show Immersive Space")
        }
        .disabled(appModel.immersiveSpaceState == .inTransition)
        .animation(.none, value: 0)
        .fontWeight(.semibold)
    }
}
