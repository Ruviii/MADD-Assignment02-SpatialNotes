# Technologies

## Technology Stack

### Platform and Language

#### Swift 6.2
- **Modern Swift**: Latest language features for safety and performance
- **Type Safety**: Strong typing prevents common runtime errors
- **Value Semantics**: Efficient data handling with structs
- **Concurrency**: Built-in async/await support for smooth user experience
- **Memory Management**: Automatic reference counting (ARC)

#### visionOS 26.1
- **Deployment Target**: Apple Vision Pro operating system
- **Spatial Computing**: First-class support for 3D interfaces
- **Eye and Hand Tracking**: Native gesture recognition
- **Passthrough**: Seamless blend of digital and physical worlds

### Core Frameworks

#### SwiftUI
The primary framework for building the user interface.

**Why SwiftUI?**
- Declarative syntax makes UI code readable and maintainable
- Automatic state management with `@State`, `@StateObject`, `@ObservedObject`
- Built-in support for visionOS-specific features
- Hot-reload during development for rapid iteration
- Cross-platform code sharing potential

**Key SwiftUI Features Used:**
- `View` protocol for all UI components
- `@Observable` macro for reactive state management
- `NavigationStack` for navigation
- `List` and `ScrollView` for content display
- `TextField` for text input
- `Button` and `Toggle` for interactions
- Custom view modifiers for styling
- `ImageBasedLighting` for 3D environment lighting

#### RealityKit
Apple's 3D rendering and spatial computing framework.

**Why RealityKit?**
- Native integration with visionOS
- Optimized for Vision Pro hardware
- Built-in physics and anchoring systems
- Seamless SwiftUI integration
- High performance with low overhead

**Key RealityKit Features Used:**
- `RealityView` - Container for 3D content in SwiftUI
- `AnchorEntity` - Spatial anchors for positioning notes
- `ModelEntity` - 3D models for note rendering
- `MeshResource` - Custom 3D geometry (planes)
- `ImageBasedLightComponent` - Realistic lighting
- `InputTargetComponent` - Gesture handling
- `HoverEffectComponent` - Hover interactions
- `Entity` hierarchy system
- Material system (`SimpleMaterial`)

#### Combine
Apple's reactive programming framework.

**Why Combine?**
- Handles asynchronous events elegantly
- Integrates seamlessly with SwiftUI
- Built-in operators for data transformation
- Memory-safe subscription management

**Key Combine Features Used:**
- `Publisher` protocol for event streams
- `@Published` property wrapper for observable values
- Subscription management for cleanup

### Data and Mathematics

#### SIMD (Single Instruction Multiple Data)
Apple's vectorized mathematics library.

**Why SIMD?**
- Hardware-accelerated vector operations
- Essential for 3D graphics and spatial computing
- Optimal performance for matrix transformations
- Type-safe vector and quaternion math

**SIMD Types Used:**
- `SIMD3<Float>` - 3D position vectors (x, y, z)
- `simd_quatf` - Rotation quaternions for orientation
- Built-in vector operations (addition, scaling, normalization)

#### Foundation
Core utilities and data structures.

**Foundation Features Used:**
- `Codable` protocol for JSON serialization
- `UUID` for unique identifiers
- `Date` for timestamps
- `FileManager` for file system access
- `JSONEncoder` / `JSONDecoder` for persistence
- `URL` for file paths

### Architecture Patterns

#### MVVM (Model-View-ViewModel)
The architectural pattern organizing the codebase.

**Components:**
- **Model** (`Note.swift`): Pure data structures with business logic
- **View** (`ContentView.swift`, `ImmersiveView.swift`, etc.): SwiftUI views
- **ViewModel** (`AppModel.swift`, `NoteStore.swift`): Observable state managers

**Benefits:**
- Clear separation of concerns
- Testable business logic
- Reactive UI updates
- Reusable components

#### Observable Pattern
State management using Swift's new Observable macro.

**Key Classes:**
- `AppModel`: Global application state
- `NoteStore`: Note collection and persistence

**Benefits:**
- Automatic view updates when data changes
- No manual notification posting
- Compiler-optimized performance
- Less boilerplate than traditional patterns

### Development Tools

#### Xcode 16+
Apple's integrated development environment.

**Features Used:**
- Swift 6.2 compiler
- visionOS SDK
- Reality Composer Pro integration
- Interface Builder
- Debugger with spatial computing support
- Vision Pro simulator

#### Reality Composer Pro
Tool for creating and editing 3D content.

**Used For:**
- RealityKit package management
- Asset organization
- 3D scene previewing

### File Formats and Standards

#### JSON (JavaScript Object Notation)
Data persistence format.

**Why JSON?**
- Human-readable for debugging
- Universal format for data exchange
- Native Swift Codable support
- Backward compatible with versioning

**Custom Serialization:**
```swift
// SIMD3<Float> → [x, y, z] array
position: [Float]

// simd_quatf → [x, y, z, w] array
orientation: [Float]
```

#### Property List (Info.plist)
Application configuration.

**Configured Settings:**
- Bundle identifier
- Display name
- Version information
- Capabilities and permissions
- Launch configuration

### System Integration

#### Documents Directory
Persistent storage location.

**Implementation:**
```swift
FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
```

**Why Documents Directory?**
- Automatic iCloud backup (if enabled)
- Survives app updates
- User-accessible via Files app
- Appropriate for user-generated content

### Performance Optimizations

#### Debouncing
Reducing unnecessary operations.

**Implementation:**
- 0.5 second delay on auto-save
- Prevents excessive file writes
- Balances responsiveness with efficiency

#### Content Hashing
Detecting actual changes.

**Implementation:**
```swift
let newHash = noteEntity.contentHash
if lastContentHash[noteID] != newHash {
    // Update texture
}
```

**Benefits:**
- Avoids redundant texture generation
- Reduces CPU and GPU load
- Maintains smooth frame rates

#### Periodic Updates
Frame-based throttling.

**Implementation:**
- Update check every 10 frames
- Immediate sync for new notes
- Balances freshness with performance

### 3D Graphics Pipeline

#### Texture Generation
Converting SwiftUI views to 3D textures.

**Process:**
1. Render SwiftUI view (`NotePanelView`) with `ImageBasedLighting`
2. Use `ImageRenderer` to create texture
3. Apply texture to `SimpleMaterial`
4. Assign material to `ModelEntity`

**Material Properties:**
- Base color from rendered texture
- Metallic: 0.0 (matte finish)
- Roughness: 0.5 (slight surface variation)

#### Mesh Generation
Creating 3D geometry for notes.

**Implementation:**
```swift
MeshResource.generatePlane(
    width: note.size.width,
    depth: note.size.height
)
```

**Orientation:**
- Horizontal plane (like a desk surface)
- Facing upward for readability
- Rotation applied via Transform

### Dependencies

#### Zero External Dependencies
All functionality built using Apple's frameworks.

**Benefits:**
- Reduced security surface
- No dependency version conflicts
- Smaller app bundle size
- Guaranteed platform compatibility
- No license concerns
- Direct Apple support

### Build Configuration

#### Debug vs Release
Different optimization levels.

**Debug Build:**
- Fast compilation
- Full debugging symbols
- Runtime checks enabled
- Larger binary size

**Release Build:**
- Full optimizations
- Minimal debugging info
- Reduced runtime checks
- Smaller binary size

#### Code Signing
Required for visionOS deployment.

**Requirements:**
- Apple Developer account
- Provisioning profile
- Development certificate
- App identifier

## Technology Choices: Rationale

### Why RealityKit Over SceneKit?
- **Modern API**: RealityKit is the future of 3D on Apple platforms
- **VisionOS Optimized**: Built specifically for spatial computing
- **Better Performance**: Hardware-accelerated for Vision Pro
- **SwiftUI Integration**: First-class support for modern UI

### Why SwiftUI Over UIKit?
- **Declarative**: Easier to reason about UI state
- **Less Code**: Automatic state binding reduces boilerplate
- **Future-Proof**: Apple's strategic direction
- **Cross-Platform**: Potential for iOS/macOS versions

### Why Local JSON Over CloudKit/CoreData?
- **Simplicity**: Easy to debug and understand
- **Portability**: Standard format for potential export features
- **Control**: Full control over data structure
- **Privacy**: Data stays local by default

### Why SIMD Over Custom Vector Classes?
- **Performance**: Hardware-accelerated operations
- **Compatibility**: Standard format for RealityKit
- **Tested**: Battle-tested Apple implementation
- **Interoperability**: Works seamlessly across frameworks

## Future Technology Considerations

### Potential Additions
- **Core Data**: For more complex data relationships
- **CloudKit**: For cross-device sync
- **RealityKit Audio**: For spatial audio feedback
- **ARKit**: For more advanced spatial anchoring
- **SharePlay**: For collaborative note spaces

### Emerging Technologies
- **visionOS 2.0+**: New APIs as platform matures
- **RealityKit 3.0**: Enhanced rendering capabilities
- **Swift 7**: Language improvements
- **Spatial Personas**: Multi-user experiences
