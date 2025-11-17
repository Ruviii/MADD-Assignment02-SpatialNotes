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
            print("🎬 ImmersiveView: RealityView make closure called")

            // Setup scene controller
            appModel.sceneController.setupScene(content: content)
            print("✅ ImmersiveView: Scene controller setup complete")
            
            // Restore existing notes as anchors at their saved positions
            // Note: On first launch, positions may be (0,0,0), which is acceptable for MVP
            lastNoteCount = appModel.noteStore.notes.count
            print("📊 ImmersiveView: Initial note count = \(lastNoteCount)")

            // Spread notes horizontally so they don't overlap
            var noteIndex = 0
            for note in appModel.noteStore.notes {
                // ALWAYS place notes in front of origin for now (camera is at origin in simulator)
                // Place at Y=1.5 (eye level) and close (Z=-0.5, just 50cm away)
                let spread: Float = 0.4 // 40cm spacing
                let offset = Float(noteIndex - lastNoteCount / 2) * spread
                var position = SIMD3<Float>(offset, 1.5, -0.5) // Eye level, very close

                print("   📐 Placing note \(noteIndex) at position \(position)")
                noteIndex += 1
                
                print("📍 ImmersiveView: Creating anchor for note \(note.id.uuidString.prefix(8)) at position \(position)")
                if let anchor = appModel.sceneController.createAnchor(for: note, at: position, orientation: note.orientation, in: content) {
                    print("✅ ImmersiveView: Anchor created successfully")
                    createNoteEntity(for: note, in: anchor)
                    noteSizes[note.id] = note.size
                } else {
                    print("❌ ImmersiveView: Failed to create anchor for note \(note.id.uuidString.prefix(8))")
                }
            }
            print("🎬 ImmersiveView: RealityView make closure complete")
        } update: { content in
            // Update camera transform from RealityViewContent
            // Note: In visionOS, camera transform is accessed through content
            // This closure runs every frame, allowing us to track camera movement
            appModel.sceneController.updateCameraTransform(from: content)
            
            // Check if notes were added/removed and sync immediately
            let currentNoteCount = appModel.noteStore.notes.count
            if currentNoteCount != lastNoteCount {
                print("🔄 Notes count changed from \(lastNoteCount) to \(currentNoteCount), syncing anchors immediately...")
                // Update state in a Task to avoid modifying during view update
                Task { @MainActor in
                    lastNoteCount = currentNoteCount
                }
                // Force immediate sync for new notes
                syncNotesWithAnchorsImmediate(content: content)
            } else {
                // Regular sync
                syncNotesWithAnchors(content: content)
            }
        }
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    // Move the entity being dragged
                    value.entity.position = value.convert(value.location3D, from: .local, to: value.entity.parent!)
                    print("🖐️ Dragging entity: \(value.entity.name ?? "unknown")")
                }
                .onEnded { value in
                    // Update note position in store when drag ends
                    let entityName = value.entity.name ?? ""
                    guard entityName.starts(with: "NoteEntity_") else { return }
                    guard let noteIDSubstring = entityName.split(separator: "_").last else { return }
                    let noteIDString = String(noteIDSubstring)
                    guard let noteID = UUID(uuidString: noteIDString) else { return }
                    guard var note = appModel.noteStore.notes.first(where: { $0.id == noteID }) else { return }

                    let worldPosition = value.entity.position(relativeTo: nil)
                    note.position = worldPosition
                    appModel.noteStore.updateNote(note)
                    print("💾 Saved note position: \(worldPosition)")
                }
        )
        .gesture(
            TapGesture()
                .targetedToAnyEntity()
                .onEnded { value in
                    // Handle tap on note - focus it
                    print("👆 Tapped entity: \(value.entity.name ?? "unknown")")

                    let entityName = value.entity.name ?? ""
                    guard entityName.starts(with: "NoteEntity_") else { return }
                    guard let noteIDSubstring = entityName.split(separator: "_").last else { return }
                    let noteIDString = String(noteIDSubstring)
                    guard let noteID = UUID(uuidString: noteIDString) else { return }
                    guard let note = appModel.noteStore.notes.first(where: { $0.id == noteID }) else { return }

                    appModel.sceneController.focus(on: note, noteStore: appModel.noteStore)
                    print("🎯 Focused on tapped note")
                }
        )
        .onAppear {
            print("👁️ ImmersiveView: onAppear called")
        }
        .onDisappear {
            print("👋 ImmersiveView: onDisappear called")
        }
        .task {
            print("⚙️ ImmersiveView: task started")
            // Initial camera update
            await MainActor.run {
                // Camera will be updated in the update closure
                print("📸 ImmersiveView: Camera update task running")
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
        print("🎨 createNoteEntity: Starting for note \(note.id.uuidString.prefix(8))")
        print("   Size: \(note.size.rawValue), Dimensions: \(note.size.width)m x \(note.size.height)m")

        // Remove existing entity if present
        anchor.children.removeAll()
        
        // Create plane entity using note's size
        // Note: generatePlane creates a horizontal plane (on XZ plane, normal +Y)
        // We'll rotate it to be vertical and face the camera
        let planeMesh = MeshResource.generatePlane(width: note.size.width, height: note.size.height)
        print("   ✅ Plane mesh created: \(note.size.width)m x \(note.size.height)m (horizontal by default)")

        // Create material with SwiftUI texture
        let material = createMaterial(for: note)
        print("   ✅ Material created")

        let entity = ModelEntity(mesh: planeMesh, materials: [material])
        entity.name = "NoteEntity_\(note.id.uuidString)"

        // Enable input and collision for interaction
        entity.generateCollisionShapes(recursive: false)
        entity.components.set(InputTargetComponent())
        entity.components.set(HoverEffectComponent())
        print("   ✅ Enabled collision and input for interaction")

        // Plane default: lying flat on XZ plane, normal points +Y (up)
        // Goal: standing upright, normal points toward camera (-Z direction, camera looks down -Z)
        // In visionOS RealityKit, the default plane from generatePlane is horizontal (normal +Y)
        
        // Try different rotation approaches to make plane visible:
        // The plane mesh from generatePlane is horizontal (normal +Y)
        // We need it vertical and facing camera (normal -Z)
        
        // Current approach: Rotate +90° around X, then 180° around Y
        // If this doesn't work, try these alternatives (uncomment one):
        
        // Option 1: Just +90° around X
        // let combinedRotation = simd_quatf(angle: Float.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        
        // Option 2: Just -90° around X (we tried this, didn't work)
        // let combinedRotation = simd_quatf(angle: -Float.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        
        // Option 3: +90° X then 180° Y (was upside down, need to flip)
        // To fix upside down: add 180° rotation around Z axis to flip it
        // let rotationX = simd_quatf(angle: Float.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        // let rotationY = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 1, 0))
        // let rotationZ = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 0, 1)) // Flip to fix upside down
        // let combinedRotation = rotationZ * rotationY * rotationX
        
        // Test: No rotation - see default orientation
        let combinedRotation = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1) // Identity quaternion (no rotation)
        
        // Alternative: -90° X then 180° Y (might be right-side up)
        // let rotationX = simd_quatf(angle: -Float.pi / 2, axis: SIMD3<Float>(1, 0, 0))
        // let rotationY = simd_quatf(angle: Float.pi, axis: SIMD3<Float>(0, 1, 0))
        // let combinedRotation = rotationY * rotationX
        
        // Use Transform to set position, orientation, and scale together
        // Position at anchor origin, rotated to face camera
        // Use nil for relativeTo to use world space (relative to anchor)
        entity.move(to: Transform(
            scale: SIMD3<Float>(1, 1, 1),
            rotation: combinedRotation,
            translation: SIMD3<Float>(0, 0, 0)
        ), relativeTo: nil)
        print("   🔄 Set transform: NO ROTATION (identity) - testing default plane orientation")
        print("   📐 Entity transform: position=\(entity.position), orientation=\(entity.orientation), scale=\(entity.scale)")
        print("   📐 Anchor world position: \(anchor.transform.translation)")

        print("   🔵 DEBUG: Note plane positioned at \(entity.position) relative to anchor")
        
        anchor.addChild(entity)
        print("   🔍 DEBUG: Entity added with scale \(entity.scale)")
        print("   🔍 DEBUG: Entity world position: \(entity.position(relativeTo: nil))")
        print("   ✅ Entity added to anchor")
        print("   📍 Anchor position: \(anchor.transform.translation)")
        print("   🎭 Entity scale: \(entity.scale)")
        print("✅ createNoteEntity: Complete for note \(note.id.uuidString.prefix(8))")
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
        print("🖼️ createMaterial: Starting for note \(note.id.uuidString.prefix(8))")
        print("   Content preview: \"\(note.content.prefix(30))...\"")

        // Create a view renderer to convert SwiftUI to texture
        // Note: ImageRenderer works on visionOS for converting SwiftUI to UIImage
        let view = NotePanelView(note: .constant(note), onUpdate: {})
        
        // Use ImageRenderer to convert SwiftUI view to image
        // Note: This runs synchronously and may block briefly, but is acceptable for on-demand updates
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0 // Higher resolution for better text quality
        renderer.isOpaque = false // Allow transparency
        print("   📏 Renderer scale: \(renderer.scale), isOpaque: \(renderer.isOpaque)")
        
        // Set proposed size to ensure text doesn't get clipped
        // Use actual view dimensions based on note size (matching NotePanelView dimensions)
        // Add generous padding to prevent any clipping
        let proposedWidth: CGFloat = {
            switch note.size {
            case .small: return 250 + 40 // width + horizontal padding (20*2)
            case .medium: return 300 + 40
            case .large: return 400 + 40
            }
        }()
        let proposedHeight: CGFloat = {
            switch note.size {
            case .small: return 160 + 44 // minHeight + top padding (20) + bottom padding (24)
            case .medium: return 240 + 44
            case .large: return 320 + 44
            }
        }()
        // Set proposed size to match exact view dimensions (no buffer needed with proper constraints)
        renderer.proposedSize = ProposedViewSize(width: proposedWidth, height: proposedHeight)
        print("   📐 Proposed size: \(proposedWidth) x \(proposedHeight)")
        
        // Render to image
        print("   🎬 Starting image render...")
        guard let image = renderer.uiImage else {
            print("   ❌ Failed to get UIImage from renderer")
            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: nil)
            material.metallic = 0.0
            material.roughness = 0.5
            return material
        }
        print("   ✅ UIImage created: \(image.size.width) x \(image.size.height) @ \(image.scale)x")

        guard let cgImage = image.cgImage else {
            print("   ❌ Failed to get CGImage from UIImage")
            var material = SimpleMaterial()
            material.color = .init(tint: .white, texture: nil)
            material.metallic = 0.0
            material.roughness = 0.5
            return material
        }
        print("   ✅ CGImage created: \(cgImage.width) x \(cgImage.height)")
        
        // Create texture from image
        do {
            print("   🎨 Creating TextureResource...")
            let texture = try TextureResource(image: cgImage, options: .init(semantic: .color))
            print("   ✅ TextureResource created successfully")

            var material = SimpleMaterial()
            material.color = .init(texture: .init(texture))
            material.metallic = 0.0
            material.roughness = 0.1
            // Ensure material is not transparent and properly lit
            material.tint = .white
            print("   ✅ Material configured with texture (size: \(cgImage.width)x\(cgImage.height))")
            print("✅ createMaterial: Complete")
            return material
        } catch {
            print("   ❌ Error creating texture: \(error)")
            print("   ℹ️ Using fallback white material")
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
