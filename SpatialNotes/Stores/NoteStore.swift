import Foundation
import Combine

/// Manages persistence and state of spatial notes
@MainActor
class NoteStore: ObservableObject {
    @Published var notes: [Note] = []
    
    private let fileName = "spatial_notes.json"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadNotes()
        
        // Auto-save when notes change
        $notes
            .dropFirst() // Skip initial value
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveNotes()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Persistence
    
    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private var fileURL: URL {
        documentsURL.appendingPathComponent(fileName)
    }
    
    func loadNotes() {
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            notes = try decoder.decode([Note].self, from: data)
            print("✅ Loaded \(notes.count) notes from: \(fileURL.path)")
        } catch {
            if (error as NSError).code != NSFileReadNoSuchFileError {
                print("⚠️ Error loading notes: \(error.localizedDescription)")
            } else {
                print("ℹ️ No existing notes file found, starting with empty store")
            }
            notes = []
        }
    }
    
    func saveNotes() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(notes)
            try data.write(to: fileURL, options: .atomic)
            print("💾 Saved \(notes.count) notes to: \(fileURL.path)")
        } catch {
            print("❌ Error saving notes: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD Operations
    
    func addNote(_ note: Note) {
        notes.append(note)
    }
    
    func updateNote(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.id == note.id }) else {
            print("⚠️ Attempted to update non-existent note: \(note.id)")
            return
        }
        var updatedNote = note
        updatedNote.touch() // Update timestamp
        notes[index] = updatedNote
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
    }
    
    func note(withID id: UUID) -> Note? {
        notes.first { $0.id == id }
    }
    
    // MARK: - Filtering
    
    /// Filters notes by category
    func notes(in category: NoteCategory?) -> [Note] {
        guard let category = category else { return notes }
        return notes.filter { $0.category == category }
    }
    
    /// Gets all unique categories from notes
    var allCategories: [NoteCategory] {
        let categories = Set(notes.map { $0.category })
        return NoteCategory.allCases.filter { categories.contains($0) }
    }
    
    /// Searches notes by content
    func searchNotes(query: String) -> [Note] {
        guard !query.isEmpty else { return notes }
        return notes.filter { note in
            note.content.localizedCaseInsensitiveContains(query)
        }
    }
}

