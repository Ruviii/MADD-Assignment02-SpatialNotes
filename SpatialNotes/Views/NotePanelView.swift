//
//  NotePanelView.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI

/// SwiftUI view for displaying a note panel in 3D space
struct NotePanelView: View {
    // MARK: - Properties
    
    @Binding var note: Note
    let onUpdate: () -> Void
    
    @State private var isEditing = false
    @State private var editedContent: String = ""
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                // Category icon and color indicator
                HStack(spacing: 6) {
                    Image(systemName: note.category.icon)
                        .foregroundColor(note.category.color)
                        .font(.caption)
                    
                    if note.category != .none {
                        Text(note.category.rawValue)
                            .font(.caption2)
                            .foregroundColor(note.category.color)
                    }
                }
                
                Spacer()
                
                Button {
                    isEditing.toggle()
                    if isEditing {
                        editedContent = note.content
                    }
                } label: {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 4)
            
            if isEditing {
                TextField("Note content", text: $editedContent, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...15)
                    .padding(.vertical, 4)
                    .onSubmit {
                        saveEdit()
                    }
                    .onChange(of: editedContent) { oldValue, newValue in
                        note.content = newValue
                        onUpdate()
                    }
            } else {
                Text(note.content.isEmpty ? "Empty note" : note.content)
                    .font(.body)
                    .foregroundColor(note.content.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.vertical, 2)
            }
        }
        .padding(16)
        .frame(width: widthForSize(note.size), alignment: .topLeading)
        .frame(minHeight: minHeightForSize(note.size))
        .fixedSize(horizontal: true, vertical: false)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay {
                    // Category color accent on left edge
                    if note.category != .none {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(note.category.color.opacity(0.3))
                            .frame(width: 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .onDisappear {
            if isEditing {
                saveEdit()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Returns the appropriate width for a note based on its size
    private func widthForSize(_ size: NoteSize) -> CGFloat {
        switch size {
        case .small: return 250
        case .medium: return 300
        case .large: return 400
        }
    }
    
    /// Returns the minimum height for a note based on its size
    private func minHeightForSize(_ size: NoteSize) -> CGFloat {
        switch size {
        case .small: return 140
        case .medium: return 200
        case .large: return 280
        }
    }
    
    private func saveEdit() {
        note.content = editedContent
        isEditing = false
        onUpdate()
    }
}

#Preview {
    NotePanelView(
        note: .constant(Note(content: "Sample note content")),
        onUpdate: {}
    )
    .padding()
}

