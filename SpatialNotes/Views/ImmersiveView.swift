//
//  ImmersiveView.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    // MARK: - Properties
    
    @Environment(AppModel.self) private var appModel
    @State private var frameCount = 0
    @State private var lastContentHashes: [UUID: Int] = [:]
    @State private var lastNoteCount = 0
    @State private var noteSizes: [UUID: NoteSize] = [:]
    
    // MARK: - Body
    
    var body: some View {
        RealityView { content in
            // Setup scene controller
            appModel.sceneController.setupScene(content: content)
            
            // Restore existing notes as anchors at their saved positions
            // Note: On first launch, positions may be (0,0,0), which is acceptable for MVP
            lastNoteCount = appModel.noteStore.notes.count
            for note in appModel.noteStore.notes {
                let position = note.position != SIMD3<Float>(0, 0, 0) 
                    ? note.position 
                    : (appModel.sceneController.cameraForward(at: 1.0) ?? SIMD3<Float>(0, 0, -1.0))
                
                if let anchor = appModel.sceneController.createAnchor(for: note, at: position, orientation: note.orientation, in: content) {
                    createNoteEntity(for: note, in: anchor)
                    noteSizes[note.id] = note.size
                }
            }
        } update: { content in
            // Update camera transform from RealityViewContent
            // Note: In visionOS, camera transform is accessed through content
            // This closure runs every frame, allowing us to track camera movement
            appModel.sceneController.updateCameraTransform(from: content)
            
            // Check if notes were added/removed and sync immediately
            let currentNoteCount = appModel.noteStore.notes.count
            if currentNoteCount != lastNoteCount {
                print("🔄 Notes count changed from \(lastNoteCount) to \(currentNoteCount), syncing anchors immediately...")
                lastNoteCount = currentNoteCount
                // Force immediate sync for new notes
                syncNotesWithAnchorsImmediate(content: content)
            } else {
                // Regular sync
                syncNotesWithAnchors(content: content)
            }
        }
        .task {
            // Initial camera update
            await MainActor.run {
                // Camera will be updated in the update closure
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Immediate sync for when notes are added/removed - creates anchors right away
    private func syncNotesWithAnchorsImmediate(content: RealityViewContent) {
        let noteStore = appModel.noteStore
        let sceneController = appModel.sceneController
        
        // Create anchors for all notes that don't have one
        for note in noteStore.notes {
            if sceneController.anchor(for: note.id) == nil {
                // New note - create anchor at saved position or camera-forward
                let position = note.position != SIMD3<Float>(0, 0, 0)
                    ? note.position
                    : (sceneController.cameraForward(at: 1.0) ?? SIMD3<Float>(0, 0, -1.0))
                
                if let anchor = sceneController.createAnchor(for: note, at: position, orientation: note.orientation, in: content) {
                    createNoteEntity(for: note, in: anchor)
                    print("✅ Immediately created anchor for new note \(note.id.uuidString.prefix(8))")
                }
            }
        }
        
        // Remove anchors for deleted notes
        let noteIDs = Set(noteStore.notes.map { $0.id })
        for noteID in sceneController.anchorMap.keys where !noteIDs.contains(noteID) {
            sceneController.removeAnchor(for: noteID)
        }
    }
    
    /// Syncs NoteStore notes with RealityKit anchors and updates SwiftUI textures
    private func syncNotesWithAnchors(content: RealityViewContent) {
        let noteStore = appModel.noteStore
        let sceneController = appModel.sceneController
        
        // Track which notes need texture updates
        var notesNeedingUpdate: Set<UUID> = []
        
        // Create anchors for new notes
        for note in noteStore.notes {
            if sceneController.anchor(for: note.id) == nil {
                // New note - create anchor at saved position or camera-forward
                let position = note.position != SIMD3<Float>(0, 0, 0)
                    ? note.position
                    : (sceneController.cameraForward(at: 1.0) ?? SIMD3<Float>(0, 0, -1.0))
                
                if let anchor = sceneController.createAnchor(for: note, at: position, orientation: note.orientation, in: content) {
                    createNoteEntity(for: note, in: anchor)
                    noteSizes[note.id] = note.size
                    notesNeedingUpdate.insert(note.id)
                }
            } else {
                // Existing note - check if content changed and update texture
                if let anchor = sceneController.anchor(for: note.id) {
                    // Update anchor position if note position changed
                    // Get position from transform translation property
                    let anchorTransform = anchor.transform
                    let anchorPosition = anchorTransform.translation
                    if abs(note.position.x - anchorPosition.x) > 0.01 ||
                       abs(note.position.y - anchorPosition.y) > 0.01 ||
                       abs(note.position.z - anchorPosition.z) > 0.01 {
                        sceneController.updateAnchor(for: note.id, position: note.position, orientation: note.orientation)
                    }
                    
                    // Mark for texture update (we'll update on content change)
                    notesNeedingUpdate.insert(note.id)
                }
            }
        }
        
        // Update textures for notes that changed
        // Note: We track content hashes to only update when content actually changes
        // This runs on MainActor, so @State mutations are safe
        Task { @MainActor in
            frameCount += 1
            
            // Update textures every 10 frames to reduce overhead, or immediately if content/size changed
            let shouldUpdate = frameCount % 10 == 0
            for noteID in notesNeedingUpdate {
                if let note = noteStore.note(withID: noteID),
                   let anchor = sceneController.anchor(for: noteID) {
                    // Create hash from content and size to detect any changes
                    let contentHash = note.content.hashValue
                    let sizeHash = note.size.rawValue.hashValue
                    let combinedHash = contentHash ^ sizeHash
                    let lastHash = lastContentHashes[noteID] ?? 0
                    
                    // Update if content or size changed or it's time for periodic update
                    if combinedHash != lastHash || shouldUpdate {
                        updateNoteEntity(for: note, in: anchor)
                        lastContentHashes[noteID] = combinedHash
                    }
                }
            }
        }
        
        // Remove anchors for deleted notes
        let noteIDs = Set(noteStore.notes.map { $0.id })
        for noteID in sceneController.anchorMap.keys where !noteIDs.contains(noteID) {
            sceneController.removeAnchor(for: noteID)
        }
    }
    
    /// Creates a ModelEntity with SwiftUI texture for a note
    private func createNoteEntity(for note: Note, in anchor: AnchorEntity) {
        // Remove existing entity if present
        anchor.children.removeAll()
        
        // Create plane entity using note's size
        let planeMesh = MeshResource.generatePlane(width: note.size.width, height: note.size.height)
        let material = createMaterial(for: note)
        let entity = ModelEntity(mesh: planeMesh, materials: [material])
        entity.name = "NoteEntity_\(note.id.uuidString)"
        
        // Position at anchor origin
        entity.position = SIMD3<Float>(0, 0, 0)
        
        // Orient plane to face camera (rotate 90 degrees around X axis to stand upright)
        // Default plane faces up, we want it to face forward
        entity.orientation = simd_quatf(angle: -Float.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        
        // Add spawn animation - scale from 0 to 1
        entity.scale = SIMD3<Float>(0, 0, 0)
        let currentTransform = entity.transform
        entity.move(
            to: Transform(
                scale: SIMD3<Float>(1, 1, 1),
                rotation: currentTransform.rotation,
                translation: currentTransform.translation
            ),
            relativeTo: anchor,
            duration: 0.3,
            timingFunction: AnimationTimingFunction.easeOut
        )
        
        anchor.addChild(entity)
        print("✅ Created note entity at anchor position \(anchor.transform.translation)")
    }
    
    /// Updates the material texture for an existing note entity
    /// Note: If size changed, recreates the entity with new mesh
    private func updateNoteEntity(for note: Note, in anchor: AnchorEntity) {
        guard let entity = anchor.children.first(where: { $0.name == "NoteEntity_\(note.id.uuidString)" }) as? ModelEntity else {
            // Entity doesn't exist, create it
            createNoteEntity(for: note, in: anchor)
            return
        }
        
        // Check if size changed - if so, recreate entity with new mesh
        let currentSize = noteSizes[note.id] ?? .medium
        if currentSize != note.size {
            // Size changed, recreate entity
            print("🔄 Note size changed from \(currentSize.rawValue) to \(note.size.rawValue), recreating entity")
            noteSizes[note.id] = note.size
            createNoteEntity(for: note, in: anchor)
            return
        }
        
        // Size unchanged, just update material with new content
        let material = createMaterial(for: note)
        entity.model?.materials = [material]
    }
    
    /// Creates a material with SwiftUI view rendered as texture
    /// Note: For visionOS, we render SwiftUI views to textures using ImageRenderer
    /// This approach works in simulator and device, but textures are updated on-demand
    private func createMaterial(for note: Note) -> RealityKit.Material {
        // Create a view renderer to convert SwiftUI to texture
        // Note: ImageRenderer works on visionOS for converting SwiftUI to UIImage
        let view = NotePanelView(note: .constant(note), onUpdate: {})
        
        // Use ImageRenderer to convert SwiftUI view to image
        // Note: This runs synchronously and may block briefly, but is acceptable for on-demand updates
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // Higher resolution for better text quality
        
        // Set proposed size to ensure text doesn't get clipped
        // Use actual view dimensions based on note size (matching NotePanelView dimensions)
        let proposedWidth: CGFloat = {
            switch note.size {
            case .small: return 250 + 32 // width + padding
            case .medium: return 300 + 32
            case .large: return 400 + 32
            }
        }()
        let proposedHeight: CGFloat = {
            switch note.size {
            case .small: return 140 + 32 // minHeight + padding
            case .medium: return 200 + 32
            case .large: return 280 + 32
            }
        }()
        renderer.proposedSize = ProposedViewSize(width: proposedWidth, height: proposedHeight)
        
        // Render to image
        guard let image = renderer.uiImage,
              let cgImage = image.cgImage else {
            // Fallback to simple material with text
            print("⚠️ Failed to render note view, using fallback material")
            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: nil)
            material.metallic = 0.0
            material.roughness = 0.5
            return material
        }
        
        // Create texture from image
        do {
            let texture = try TextureResource(image: cgImage, options: .init(semantic: .color))
            var material = SimpleMaterial()
            material.color = .init(texture: .init(texture))
            material.metallic = 0.0
            material.roughness = 0.1
            return material
        } catch {
            print("⚠️ Error creating texture: \(error)")
            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: nil)
            material.metallic = 0.0
            material.roughness = 0.5
            return material
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
