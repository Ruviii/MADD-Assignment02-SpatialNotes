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
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .onSubmit {
                        saveEdit()
                    }
                    .onChange(of: editedContent) { oldValue, newValue in
                        note.content = newValue
                        onUpdate()
                    }
            } else {
                // Display mode - show note content
                // Note: ScrollView doesn't render well in ImageRenderer, so use Text with lineLimit
                Text(note.content.isEmpty ? "Empty note" : note.content)
                    .font(.body)
                    .foregroundColor(note.content.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
        }
        .frame(width: widthForSize(note.size), alignment: .topLeading)
        .frame(height: contentHeightForSize(note.size))
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24) // Extra bottom padding to prevent text clipping
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
    
    /// Returns the content area height (without padding)
    private func contentHeightForSize(_ size: NoteSize) -> CGFloat {
        switch size {
        case .small: return 160
        case .medium: return 240
        case .large: return 320
        }
    }

    /// Returns the maximum height for scrollable content area
    private func maxContentHeightForSize(_ size: NoteSize) -> CGFloat {
        // Content height - header height - header bottom padding - VStack spacing
        return contentHeightForSize(size) - 30 - 4 - 12
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

