
import Foundation
import SwiftUI
import simd

/// Represents the size of a note in 3D space
enum NoteSize: String, Codable, CaseIterable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var width: Float {
        switch self {
        case .small: return 0.3
        case .medium: return 0.5
        case .large: return 0.7
        }
    }

    var height: Float {
        switch self {
        // Heights adjusted to match SwiftUI view aspect ratios
        // Small: 250×160 ratio = 1.5625, so height = 0.3/1.5625 ≈ 0.192
        case .small: return 0.192
        // Medium: 300×240 ratio = 1.25, so height = 0.5/1.25 = 0.4
        case .medium: return 0.4
        // Large: 400×320 ratio = 1.25, so height = 0.7/1.25 = 0.56
        case .large: return 0.56
        }
    }
}

/// Represents a category for organizing notes
enum NoteCategory: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case work = "Work"
    case personal = "Personal"
    case reminder = "Reminder"
    case idea = "Idea"
    case todo = "Todo"
    
    var id: String { rawValue }
    
    /// Color associated with this category
    var color: Color {
        switch self {
        case .none: return .gray
        case .work: return .blue
        case .personal: return .green
        case .reminder: return .orange
        case .idea: return .purple
        case .todo: return .red
        }
    }
    
    /// System icon for this category
    var icon: String {
        switch self {
        case .none: return "note.text"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .reminder: return "bell.fill"
        case .idea: return "lightbulb.fill"
        case .todo: return "checklist"
        }
    }
}

/// Represents a spatial note anchored in 3D space
struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    var position: SIMD3<Float>
    var orientation: simd_quatf
    var category: NoteCategory
    var size: NoteSize
    let createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), content: String = "", position: SIMD3<Float> = SIMD3<Float>(0, 0, 0), orientation: simd_quatf = simd_quatf(ix: 0, iy: 0, iz: 0, r: 1), category: NoteCategory = .none, size: NoteSize = .medium, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.content = content
        self.position = position
        self.orientation = orientation
        self.category = category
        self.size = size
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    /// Updates the note's updatedAt timestamp
    mutating func touch() {
        updatedAt = Date()
    }
}

// MARK: - simd Serialization Helpers

extension Note {
    /// Encodes SIMD3<Float> position as [Float] for JSON
    enum CodingKeys: String, CodingKey {
        case id, content, position, orientation, category, size, createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        content = try container.decode(String.self, forKey: .content)
        
        // Decode position as array and convert to SIMD3
        let positionArray = try container.decode([Float].self, forKey: .position)
        guard positionArray.count == 3 else {
            throw DecodingError.dataCorruptedError(forKey: .position, in: container, debugDescription: "Position array must have 3 elements")
        }
        position = SIMD3<Float>(positionArray[0], positionArray[1], positionArray[2])
        
        // Decode orientation quaternion as array [ix, iy, iz, r]
        let orientationArray = try container.decode([Float].self, forKey: .orientation)
        guard orientationArray.count == 4 else {
            throw DecodingError.dataCorruptedError(forKey: .orientation, in: container, debugDescription: "Orientation array must have 4 elements")
        }
        orientation = simd_quatf(ix: orientationArray[0], iy: orientationArray[1], iz: orientationArray[2], r: orientationArray[3])
        
        // Decode category (with fallback to .none for backward compatibility)
        category = (try? container.decode(NoteCategory.self, forKey: .category)) ?? .none
        
        // Decode size (with fallback to .medium for backward compatibility)
        size = (try? container.decode(NoteSize.self, forKey: .size)) ?? .medium
        
        // Decode timestamps (with fallback to current date for backward compatibility)
        createdAt = (try? container.decode(Date.self, forKey: .createdAt)) ?? Date()
        updatedAt = (try? container.decode(Date.self, forKey: .updatedAt)) ?? Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(content, forKey: .content)
        
        // Encode position as array
        try container.encode([position.x, position.y, position.z], forKey: .position)
        
        // Encode orientation quaternion as array
        try container.encode([orientation.vector.x, orientation.vector.y, orientation.vector.z, orientation.vector.w], forKey: .orientation)
        
        // Encode category
        try container.encode(category, forKey: .category)
        
        // Encode size
        try container.encode(size, forKey: .size)
        
        // Encode timestamps
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Transform Helpers

extension Note {
    /// Creates a transform matrix from position and orientation
    var transform: simd_float4x4 {
        let rotation = simd_float4x4(orientation)
        // Create translation matrix by setting the 4th column (translation vector)
        var translation = matrix_identity_float4x4
        translation.columns.3 = SIMD4<Float>(position.x, position.y, position.z, 1.0)
        return translation * rotation
    }
    
    /// Creates a Note from a transform matrix (extracts position and orientation)
    static func from(transform: simd_float4x4) -> Note {
        let position = SIMD3<Float>(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        let orientation = simd_quatf(transform)
        return Note(position: position, orientation: orientation)
    }
}

