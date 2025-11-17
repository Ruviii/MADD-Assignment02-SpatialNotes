import SwiftUI
import RealityKit
import Combine

/// Manages the RealityKit scene and spatial anchors for notes
@MainActor
class SpatialSceneController: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentCameraTransform: simd_float4x4?
    
    // MARK: - Private Properties
    
    var anchorMap: [UUID: AnchorEntity] = [:]
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        print("🎬 SpatialSceneController initialized")
    }
    
    // MARK: - Scene Setup
    
    /// Sets up the RealityView content
    /// Note: Content is passed directly to methods that need it rather than stored
    func setupScene(content: RealityViewContent) {
        // Add ambient lighting to ensure entities are visible
        let ambientLight = PointLight()
        ambientLight.light.intensity = 10000
        ambientLight.position = [0, 2, 0]

        let lightAnchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
        lightAnchor.addChild(ambientLight)
        content.add(lightAnchor)

        print("💡 Added ambient lighting to scene")
        print("✅ Scene setup complete")
    }
    
    // MARK: - Camera Tracking
    
    /// Updates camera transform from RealityViewContent
    /// Note: In visionOS, camera transform is accessed through RealityViewContent
    /// For simulator, we use a default transform at origin looking forward
    func updateCameraTransform(from content: RealityViewContent) {
        // In visionOS, we can access camera through the content
        // For now, we'll use a default transform for simulator compatibility
        // In a production app, you might access camera through content.camera or similar API
        if currentCameraTransform == nil {
            // Default camera at origin looking forward (negative Z direction)
            // Create a proper transform: camera at (0, 0, 0) looking down -Z axis
            let transform = matrix_identity_float4x4
            // Forward is -Z, so we want to look down negative Z
            // This means notes should spawn at (0, 0, -1.0) which is 1m in front
            currentCameraTransform = transform
            print("📷 Initialized default camera transform at origin")
        }
        
        // Note: For actual device camera access, you may need to use:
        // - content.camera (if available in your SDK version)
        // - Scene events with camera tracking
        // - ARKit camera APIs if available
    }
    
    /// Updates camera transform from scene (legacy method, kept for compatibility)
    /// Note: Scene doesn't directly provide cameraTransform in all SDK versions
    func updateCameraTransform(from scene: RealityKit.Scene) {
        // Scene doesn't have direct cameraTransform access
        // Use updateCameraTransform(from: RealityViewContent) instead
        if currentCameraTransform == nil {
            currentCameraTransform = matrix_identity_float4x4
        }
    }
    
    /// Gets the forward direction from camera transform
    /// Returns position 1.0m in front of camera (along negative Z axis in camera space)
    func cameraForward(at distance: Float = 1.0) -> SIMD3<Float>? {
        guard let transform = currentCameraTransform else {
            print("⚠️ Cannot get camera forward: transform unavailable")
            return nil
        }
        
        // Camera position is the translation (4th column)
        let cameraPosition = SIMD3<Float>(
            transform.columns.3.x,
            transform.columns.3.y,
            transform.columns.3.z
        )
        
        // Forward vector in camera space is -Z, which in world space is the negative of the 3rd column
        // For identity matrix, forward is (0, 0, -1)
        let forward = SIMD3<Float>(
            -transform.columns.2.x,
            -transform.columns.2.y,
            -transform.columns.2.z
        )
        
        // If forward is zero (identity matrix), use default forward direction
        let forwardDirection = length(forward) > 0.01 ? forward : SIMD3<Float>(0, 0, -1)
        
        let targetPosition = cameraPosition + forwardDirection * distance
        print("📷 Camera at \(cameraPosition), forward \(forwardDirection), target \(targetPosition)")
        return targetPosition
    }
    
    // MARK: - Anchor Management
    
    /// Creates an anchor entity for a note at the specified position
    func createAnchor(for note: Note, at position: SIMD3<Float>, orientation: simd_quatf? = nil, in content: RealityViewContent) -> AnchorEntity? {
        // Remove existing anchor if present
        removeAnchor(for: note.id)

        // Create world anchor using matrix identity
        let anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
        anchor.name = "NoteAnchor_\(note.id.uuidString)"

        // Set position and orientation directly
        anchor.position = position
        if let orientation = orientation {
            anchor.orientation = orientation
        }

        print("   🔧 Setting anchor position to \(position)")
        print("   🔧 Anchor transform before adding: \(anchor.transform.translation)")

        anchorMap[note.id] = anchor
        content.add(anchor)

        print("   🔧 Anchor transform after adding: \(anchor.transform.translation)")
        print("✅ Created anchor for note \(note.id.uuidString.prefix(8)) at position \(position)")
        return anchor
    }
    
    /// Removes anchor for a note
    func removeAnchor(for noteID: UUID) {
        guard let anchor = anchorMap[noteID] else { return }
        
        anchor.removeFromParent()
        anchorMap.removeValue(forKey: noteID)
        print("🗑️ Removed anchor for note \(noteID.uuidString.prefix(8))")
    }
    
    /// Gets anchor for a note
    func anchor(for noteID: UUID) -> AnchorEntity? {
        anchorMap[noteID]
    }
    
    /// Updates anchor position and orientation for a note
    func updateAnchor(for noteID: UUID, position: SIMD3<Float>, orientation: simd_quatf) {
        guard let anchor = anchorMap[noteID] else {
            print("⚠️ Cannot update anchor: not found for note \(noteID.uuidString.prefix(8))")
            return
        }
        
        // Update anchor transform with new position and orientation
        let currentTransform = anchor.transform
        let newTransform = Transform(
            scale: currentTransform.scale,
            rotation: orientation,
            translation: position
        )
        anchor.move(to: newTransform, relativeTo: nil, duration: 0.0)
        print("🔄 Updated anchor for note \(noteID.uuidString.prefix(8))")
    }
    
    // MARK: - Focus Behavior
    
    /// Focuses on a note by moving it to camera-forward position
    /// Note: This updates the note's position in the store for persistence
    func focus(on note: Note, distance: Float = 0.8, noteStore: NoteStore? = nil) {
        guard let targetPosition = cameraForward(at: distance) else {
            print("⚠️ Cannot focus: camera transform unavailable")
            return
        }
        
        // Get current anchor
        // Note: For focus, we animate existing anchor, so we don't need to create a new one here
        guard let anchor = anchorMap[note.id] else {
            print("⚠️ Cannot focus: anchor not found for note \(note.id.uuidString.prefix(8))")
            return
        }
        
        // Animate anchor to target position
        // Note: In simulator, we use RealityKit's move animation
        // For smoother animation, this uses ease-in-out timing
        // Create a new transform with the target position, keeping current orientation
        let currentTransform = anchor.transform
        let newTransform = Transform(
            scale: currentTransform.scale,
            rotation: currentTransform.rotation,
            translation: targetPosition
        )
        
        // Animate with ease-in-out
        anchor.move(to: newTransform, relativeTo: nil, duration: 0.5, timingFunction: AnimationTimingFunction.easeInOut)
        
        // Update stored position so it persists
        // Note: We update the note's stored position to reflect the new focused position
        if let noteStore = noteStore {
            var updatedNote = note
            updatedNote.position = targetPosition
            noteStore.updateNote(updatedNote)
        }
        
        print("🎯 Focused on note \(note.id.uuidString.prefix(8)) at \(targetPosition)")
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        anchorMap.values.forEach { $0.removeFromParent() }
        anchorMap.removeAll()
        print("🧹 SpatialSceneController cleaned up")
    }
}

