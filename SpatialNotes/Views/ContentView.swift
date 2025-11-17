//
//  ContentView.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    // MARK: - Properties
    
    @Environment(AppModel.self) private var appModel
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left: Notes List - takes 60% of available width
                NotesListView(
                    noteStore: appModel.noteStore,
                    onFocusNote: { note in
                        appModel.sceneController.focus(on: note, noteStore: appModel.noteStore)
                    },
                    onEditNote: { note in
                        appModel.noteStore.updateNote(note)
                    },
                    onDeleteNote: { note in
                        appModel.sceneController.removeAnchor(for: note.id)
                        appModel.noteStore.deleteNote(note)
                    }
                )
                .frame(width: geometry.size.width * 0.6)
                .frame(maxHeight: .infinity)
                
                Divider()
                
                // Right: Toolbar and Controls - takes remaining 40% of width
                VStack(spacing: 20) {
                    ToolbarView {
                        spawnNoteInFront()
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Immersion Style")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("Style", selection: Binding(
                            get: { appModel.immersionStyleSelection },
                            set: { appModel.immersionStyleSelection = $0 }
                        )) {
                            ForEach(AppModel.ImmersionStyleSelection.allCases, id: \.self) { style in
                                Text(style.rawValue).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(appModel.immersiveSpaceState == .open)
                    }
                    
                    ToggleImmersiveSpaceButton()
                    
                    Spacer()
                }
                .frame(width: geometry.size.width * 0.4)
                .frame(maxHeight: .infinity)
                .padding()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    // MARK: - Private Methods
    
    /// Spawns a new note 1.0m in front of the camera
    /// Note: If immersive space is not open, note will be created at default position
    /// and will appear when the space is opened
    private func spawnNoteInFront() {
        var note: Note
        
        if appModel.immersiveSpaceState == .open {
            // Try to get camera position if space is open
            if let position = appModel.sceneController.cameraForward(at: 1.0) {
                note = Note(content: "New note", position: position)
                print("✅ Spawned note at camera position \(position)")
            } else {
                // Camera unavailable, use default position
                note = Note(content: "New note", position: SIMD3<Float>(0, 0, -1.0))
                print("⚠️ Camera unavailable, spawned note at default position")
            }
        } else {
            // Space not open, create note at default position
            // It will appear when the immersive space opens
            note = Note(content: "New note", position: SIMD3<Float>(0, 0, -1.0))
            print("ℹ️ Spawned note at default position (immersive space not open)")
        }
        
        appModel.noteStore.addNote(note)
        print("📝 Added note to store. Total notes: \(appModel.noteStore.notes.count)")
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
