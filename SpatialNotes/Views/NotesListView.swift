//
//  NotesListView.swift
//  SpatialNotes
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import SwiftUI

/// List view for managing notes
struct NotesListView: View {
    // MARK: - Properties
    
    @Environment(AppModel.self) private var appModel
    @ObservedObject var noteStore: NoteStore
    let onFocusNote: (Note) -> Void
    let onEditNote: (Note) -> Void
    let onDeleteNote: (Note) -> Void
    
    @State private var editingNote: Note?
    @State private var selectedCategory: NoteCategory? = nil
    @State private var searchText: String = ""
    
    // Computed property for filtered notes
    private var filteredNotes: [Note] {
        var notes = noteStore.notes(in: selectedCategory)
        
        // Apply search filter
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort by most recently updated
        return notes.sorted { $0.updatedAt > $1.updatedAt }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with filter
            VStack(alignment: .leading, spacing: 16) {
            Text("Notes")
                .font(.headline)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.caption)
                    
                    TextField("Search notes...", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.body)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        // "All" button
                        Button {
                            selectedCategory = nil
                        } label: {
                            Text("All")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCategory == nil ? Color.accentColor : Color.secondary.opacity(0.15))
                                .foregroundColor(selectedCategory == nil ? .white : .primary)
                                .cornerRadius(10)
                        }
                        
                        // Category buttons
                        ForEach(NoteCategory.allCases.filter { $0 != .none }) { category in
                            Button {
                                selectedCategory = selectedCategory == category ? nil : category
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: category.icon)
                                        .font(.caption2)
                                    Text(category.rawValue)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? category.color : Color.secondary.opacity(0.15))
                                .foregroundColor(selectedCategory == category ? .white : category.color)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 8)
            
            if filteredNotes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No notes yet")
                        .foregroundColor(.secondary)
                    Text("Tap 'Spawn in front' to create one")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredNotes) { note in
                        NoteRowView(
                            note: note,
                            onFocus: { onFocusNote(note) },
                            onEdit: { editingNote = note },
                            onDelete: { onDeleteNote(note) }
                        )
                        .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
            }
        }
        .sheet(item: $editingNote) { note in
            NoteEditView(note: note, onSave: { updatedNote in
                noteStore.updateNote(updatedNote)
                    onEditNote(updatedNote)
                editingNote = nil
            })
        }
    }
}

struct NoteRowView: View {
    let note: Note
    let onFocus: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category color indicator
            if note.category != .none {
                RoundedRectangle(cornerRadius: 3)
                    .fill(note.category.color)
                    .frame(width: 4)
                    .frame(maxHeight: .infinity)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    if note.category != .none {
                        Image(systemName: note.category.icon)
                            .foregroundColor(note.category.color)
                            .font(.caption2)
                    }
                Text(note.content.isEmpty ? "Empty note" : note.content)
                    .lineLimit(2)
                    .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                HStack(spacing: 6) {
                Text("ID: \(note.id.uuidString.prefix(8))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(note.updatedAt, style: .relative)
                        .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Menu {
                Button {
                    onFocus()
                } label: {
                    Label("Go to", systemImage: "location")
                }
                
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Divider()
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.05))
        }
    }
}

struct NoteEditView: View {
    @State var note: Note
    let onSave: (Note) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Note content", text: $note.content, axis: .vertical)
                        .lineLimit(3...10)
                }
                
                Section("Category") {
                    Picker("Category", selection: $note.category) {
                        ForEach(NoteCategory.allCases) { category in
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue)
                            }
                            .tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Size") {
                    Picker("Size", selection: $note.size) {
                        ForEach(NoteSize.allCases, id: \.self) { size in
                            Text(size.rawValue).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(note)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    let appModel = AppModel()
    return NotesListView(
        noteStore: appModel.noteStore,
        onFocusNote: { _ in },
        onEditNote: { _ in },
        onDeleteNote: { _ in }
    )
    .environment(appModel)
}


