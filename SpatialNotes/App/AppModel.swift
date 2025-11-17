//
//  AppModel.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI

/// Maintains app-wide state and coordinates between components
@MainActor
@Observable
class AppModel {
    // MARK: - Immersive Space Configuration
    
    let immersiveSpaceID = "ImmersiveSpace"
    
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    
    var immersiveSpaceState = ImmersiveSpaceState.closed
    
    enum ImmersionStyleSelection: String, CaseIterable {
        case mixed = "Mixed"
        case progressive = "Progressive"
        
        var immersionStyle: ImmersionStyle {
            switch self {
            case .mixed:
                return .mixed
            case .progressive:
                return .progressive
            }
        }
    }
    
    var immersionStyleSelection: ImmersionStyleSelection = .mixed
    
    /// Returns the current ImmersionStyle based on selection
    /// Note: This is read-only since ImmersionStyle is a protocol
    var immersionStyle: ImmersionStyle {
        immersionStyleSelection.immersionStyle
    }
    
    // MARK: - Core Components
    
    /// Manages note persistence and state
    let noteStore = NoteStore()
    
    /// Manages RealityKit scene and spatial anchors
    let sceneController = SpatialSceneController()
    
    // MARK: - Initialization
    
    init() {
        // Setup is handled by individual components
    }
}
