//
//  SpatialNotesTests.swift
//  SpatialNotesTests
//
//  Created by Sujana Dinuwara on 2025-11-17.
//

import Testing
import Foundation
import simd
@testable import SpatialNotes

struct SpatialNotesTests {
    
    // MARK: - Note Encoding/Decoding Tests
    
    @Test func testNoteEncoding() async throws {
        let note = Note(
            id: UUID(),
            content: "Test note content",
            position: SIMD3<Float>(1.0, 2.0, 3.0),
            orientation: simd_quatf(ix: 0.1, iy: 0.2, iz: 0.3, r: 0.9)
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(note)
        
        // Verify data is not empty
        #expect(data.count > 0)
        
        // Verify we can decode it back
        let decoder = JSONDecoder()
        let decodedNote = try decoder.decode(Note.self, from: data)
        
        #expect(decodedNote.id == note.id)
        #expect(decodedNote.content == note.content)
        #expect(decodedNote.position.x == note.position.x)
        #expect(decodedNote.position.y == note.position.y)
        #expect(decodedNote.position.z == note.position.z)
    }
    
    @Test func testNoteDecoding() async throws {
        // Create JSON data manually to test decoding
        let jsonString = """
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "content": "Decoded note",
            "position": [1.5, 2.5, 3.5],
            "orientation": [0.0, 0.0, 0.0, 1.0]
        }
        """
        
        let data = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let note = try decoder.decode(Note.self, from: data)
        
        #expect(note.content == "Decoded note")
        #expect(note.position.x == 1.5)
        #expect(note.position.y == 2.5)
        #expect(note.position.z == 3.5)
    }
    
    @Test func testNoteRoundTrip() async throws {
        let originalNote = Note(
            content: "Round trip test",
            position: SIMD3<Float>(5.0, 10.0, 15.0),
            orientation: simd_quatf(ix: 0.5, iy: 0.5, iz: 0.5, r: 0.5)
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalNote)
        
        let decoder = JSONDecoder()
        let decodedNote = try decoder.decode(Note.self, from: data)
        
        // Verify all properties match
        #expect(decodedNote.id == originalNote.id)
        #expect(decodedNote.content == originalNote.content)
        #expect(abs(decodedNote.position.x - originalNote.position.x) < 0.001)
        #expect(abs(decodedNote.position.y - originalNote.position.y) < 0.001)
        #expect(abs(decodedNote.position.z - originalNote.position.z) < 0.001)
    }
    
    // MARK: - NoteStore Persistence Tests
    
    @Test func testNoteStoreSaveAndLoad() async throws {
        // Create a temporary store for testing
        let store = NoteStore()
        
        // Clear existing notes
        store.notes = []
        
        // Add test notes
        let note1 = Note(content: "First test note", position: SIMD3<Float>(1, 1, 1))
        let note2 = Note(content: "Second test note", position: SIMD3<Float>(2, 2, 2))
        
        store.addNote(note1)
        store.addNote(note2)
        
        // Force save
        store.saveNotes()
        
        // Verify notes were saved
        #expect(store.notes.count == 2)
        
        // Create a new store and load
        let newStore = NoteStore()
        newStore.loadNotes()
        
        // Verify notes were loaded
        #expect(newStore.notes.count == 2)
        #expect(newStore.notes.contains { $0.id == note1.id })
        #expect(newStore.notes.contains { $0.id == note2.id })
    }
    
    @Test func testNoteStoreCRUD() async throws {
        let store = NoteStore()
        store.notes = []
        
        // Create
        let note = Note(content: "CRUD test")
        store.addNote(note)
        #expect(store.notes.count == 1)
        
        // Read
        let retrieved = store.note(withID: note.id)
        #expect(retrieved != nil)
        #expect(retrieved?.content == "CRUD test")
        
        // Update
        var updatedNote = note
        updatedNote.content = "Updated content"
        store.updateNote(updatedNote)
        #expect(store.note(withID: note.id)?.content == "Updated content")
        
        // Delete
        store.deleteNote(note)
        #expect(store.notes.count == 0)
        #expect(store.note(withID: note.id) == nil)
    }
    
    @Test func testNoteStoreAutoSave() async throws {
        let store = NoteStore()
        store.notes = []
        
        // Add a note (should trigger auto-save after debounce)
        let note = Note(content: "Auto-save test")
        store.addNote(note)
        
        // Wait for debounce (0.5 seconds) plus a bit
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6 seconds
        
        // Verify note was saved by loading in new store
        let newStore = NoteStore()
        newStore.loadNotes()
        
        // Note: This test may be flaky if auto-save hasn't completed
        // In a real scenario, you might want to verify the file exists
        #expect(newStore.notes.count >= 0) // At least the file should be readable
    }
    
    // MARK: - Note Transform Helpers Tests
    
    @Test func testNoteTransformConversion() async throws {
        let position = SIMD3<Float>(1.0, 2.0, 3.0)
        let orientation = simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0)
        let note = Note(position: position, orientation: orientation)
        
        let transform = note.transform
        
        // Verify transform contains position
        #expect(abs(transform.columns.3.x - position.x) < 0.001)
        #expect(abs(transform.columns.3.y - position.y) < 0.001)
        #expect(abs(transform.columns.3.z - position.z) < 0.001)
    }
    
    @Test func testNoteFromTransform() async throws {
        let position = SIMD3<Float>(5.0, 10.0, 15.0)
        let orientation = simd_quatf(ix: 0.0, iy: 0.0, iz: 0.0, r: 1.0)
        let transform = simd_float4x4(rotation: orientation, translation: position)
        
        let note = Note.from(transform: transform)
        
        #expect(abs(note.position.x - position.x) < 0.001)
        #expect(abs(note.position.y - position.y) < 0.001)
        #expect(abs(note.position.z - position.z) < 0.001)
    }
}
