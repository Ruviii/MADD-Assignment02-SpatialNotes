# Development Guide

## Getting Started

### Prerequisites

#### Hardware Requirements
- **Mac**: Apple Silicon (M1/M2/M3) or Intel Mac running macOS Sonoma or later
- **Vision Pro** (optional): For testing on actual hardware
- **Minimum 8GB RAM**: 16GB recommended for smooth development

#### Software Requirements
- **macOS**: Sonoma (14.0) or later
- **Xcode**: 16.0 or later
- **Swift**: 6.2 or later (included with Xcode)
- **visionOS SDK**: 26.1 or later (included with Xcode)
- **Apple Developer Account**: Required for device testing (free tier sufficient for development)

### Installation

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd SpatialNotes
```

#### 2. Open the Project
```bash
open SpatialNotes.xcodeproj
```

Or double-click `SpatialNotes.xcodeproj` in Finder.

#### 3. Configure Code Signing
1. Open the project in Xcode
2. Select the **SpatialNotes** target
3. Go to **Signing & Capabilities**
4. Select your **Team** from the dropdown
5. Xcode will automatically generate a provisioning profile

#### 4. Build the Project
- **Simulator**: Select "Apple Vision Pro" simulator from device menu
- **Device**: Connect Vision Pro via USB-C and select it from device menu
- Press `Cmd+B` to build or `Cmd+R` to build and run

### Project Structure

```
SpatialNotes/
├── SpatialNotes/                          # Main application target
│   ├── App/
│   │   ├── SpatialNotesApp.swift         # App entry point, scene setup
│   │   └── AppModel.swift                # Central app state (@Observable)
│   ├── Models/
│   │   └── Note.swift                    # Note data model with Codable
│   ├── Stores/
│   │   └── NoteStore.swift               # Persistence and CRUD operations
│   ├── Controllers/
│   │   └── SpatialSceneController.swift  # RealityKit scene management
│   ├── Views/
│   │   ├── ContentView.swift             # Main window (split layout)
│   │   ├── ImmersiveView.swift           # 3D immersive space
│   │   ├── NotePanelView.swift           # Individual note rendering
│   │   ├── NotesListView.swift           # Notes list with filters
│   │   ├── ToolbarView.swift             # Spawn controls
│   │   └── ToggleImmersiveSpaceButton.swift  # Immersive toggle
│   ├── Assets.xcassets/                  # Images, colors, icons
│   └── Info.plist                        # App configuration
├── Packages/
│   └── RealityKitContent/                # RealityKit package (3D assets)
├── SpatialNotes.xcodeproj/               # Xcode project
└── docs/                                 # Documentation
```

### Architecture Overview

#### MVVM Pattern
```
┌─────────────┐      ┌──────────────┐      ┌─────────┐
│    Views    │─────▶│  ViewModels  │─────▶│ Models  │
│  (SwiftUI)  │◀─────│  (Observable)│◀─────│ (Data)  │
└─────────────┘      └──────────────┘      └─────────┘
     │                     │                     │
     │                     │                     │
  UI Layer          State Layer            Data Layer
```

#### Key Components

**AppModel.swift**: Global application state
- Manages immersive space state
- Coordinates between views
- Singleton accessible throughout app

**NoteStore.swift**: Data management
- CRUD operations for notes
- JSON persistence with debouncing
- Observable for reactive UI updates

**SpatialSceneController.swift**: 3D scene management
- Creates and manages RealityKit entities
- Handles spatial anchoring
- Manages texture updates and gestures

## Development Workflow

### Running the App

#### In Simulator
1. Select "Apple Vision Pro" from device menu
2. Press `Cmd+R` to run
3. Use mouse/trackpad for interaction:
   - Click and drag to move notes
   - Click to tap notes
   - Use window controls to resize

**Simulator Limitations:**
- No hand tracking
- No eye tracking
- Limited spatial perception
- Lower performance than device

#### On Device
1. Connect Vision Pro via USB-C
2. Trust the computer on Vision Pro
3. Select Vision Pro from device menu
4. Press `Cmd+R` to run
5. Interact naturally with hands and eyes

**Device Benefits:**
- Real spatial interaction
- Accurate hand tracking
- True immersive experience
- Performance testing

### Making Changes

#### Adding a New Feature

**Example: Adding Note Priority**

1. **Update the Model** (`Models/Note.swift`)
```swift
struct Note: Identifiable, Codable {
    // Existing properties...
    var priority: Priority = .normal

    enum Priority: String, Codable {
        case low, normal, high
    }
}
```

2. **Update the Store** (`Stores/NoteStore.swift`)
```swift
func updateNotePriority(noteID: UUID, priority: Note.Priority) {
    if let index = notes.firstIndex(where: { $0.id == noteID }) {
        notes[index].priority = priority
    }
}
```

3. **Update the UI** (`Views/NotePanelView.swift`)
```swift
var body: some View {
    VStack {
        // Existing content...
        Text("Priority: \(note.priority.rawValue)")
    }
}
```

4. **Test the Changes**
   - Build and run
   - Create a note
   - Verify priority displays and persists

#### Modifying Existing Features

**Example: Changing Note Colors**

1. Locate the category definition in `Models/Note.swift`
2. Modify the `color` property:
```swift
var color: Color {
    switch category {
    case .work: return .orange  // Change to .purple
    // ...
    }
}
```
3. Build and run to see changes

### Debugging

#### Common Debugging Tools

**Print Debugging**
```swift
print("Note position: \(note.position)")
print("Note count: \(noteStore.notes.count)")
```

**Breakpoints**
- Click line number in Xcode to set breakpoint
- Run app in debug mode
- Inspect variables when execution pauses

**View Hierarchy Debugger**
- Run app
- Click "Debug View Hierarchy" button in Xcode
- Inspect 3D view structure

**Reality Composer Pro**
- Open RealityKit package
- Preview 3D content
- Validate assets

#### Common Issues

**Issue: Notes don't appear in immersive space**
- Check `ImmersiveView.swift` for anchor creation
- Verify note positions are not NaN or infinity
- Ensure RealityKit content loads properly

**Issue: Notes don't save**
- Check file permissions
- Verify JSON encoding/decoding
- Look for errors in console

**Issue: Texture not updating**
- Check content hash comparison
- Verify `updateTexture` is called
- Ensure SwiftUI view renders correctly

**Issue: Gestures not working**
- Verify `InputTargetComponent` is added
- Check gesture recognizer setup
- Ensure entity has collision shape

### Testing

#### Manual Testing Checklist

**Note Creation:**
- [ ] Spawn note in front
- [ ] Note appears at correct position
- [ ] Note has default category and size
- [ ] Note saves to disk

**Note Editing:**
- [ ] Edit note content
- [ ] Change category
- [ ] Change size
- [ ] Changes persist after app restart

**Note Interaction:**
- [ ] Drag note in 3D space
- [ ] Tap note to focus
- [ ] Position persists after drag
- [ ] Texture updates when content changes

**Immersive Mode:**
- [ ] Toggle immersive space
- [ ] Notes render correctly in 3D
- [ ] Gestures work in immersive space
- [ ] Can return to window mode

**Search and Filter:**
- [ ] Search finds correct notes
- [ ] Category filter works
- [ ] Sort by recent works
- [ ] Empty states display correctly

#### Unit Testing (Future Enhancement)
Currently no automated tests. Future addition recommended:
- Model tests for Note struct
- Store tests for NoteStore CRUD
- Serialization tests for JSON encoding/decoding

### Performance Profiling

#### Using Instruments

1. Product → Profile (Cmd+I)
2. Select profiling template:
   - **Time Profiler**: CPU usage
   - **Allocations**: Memory usage
   - **Metal System Trace**: GPU performance
3. Record while using app
4. Analyze bottlenecks

#### Performance Tips
- Minimize texture regeneration
- Use content hashing to detect changes
- Debounce frequent operations
- Reuse entities when possible
- Avoid complex SwiftUI views for textures

### Code Style and Conventions

#### Swift Style Guide
Follow Apple's Swift API Design Guidelines:

**Naming:**
- `lowerCamelCase` for properties and methods
- `UpperCamelCase` for types
- Descriptive names (avoid abbreviations)

**Example:**
```swift
// Good
func createNoteAnchor(for note: Note) -> AnchorEntity

// Bad
func mkAnchor(n: Note) -> AnchorEntity
```

**Formatting:**
- 4 spaces for indentation (no tabs)
- Opening brace on same line
- Explicit `self` only when required
- Mark sections with `// MARK:`

**Example:**
```swift
class NoteStore: ObservableObject {
    // MARK: - Properties
    @Published var notes: [Note] = []

    // MARK: - Initialization
    init() {
        loadNotes()
    }

    // MARK: - Public Methods
    func addNote(_ note: Note) {
        notes.append(note)
    }
}
```

#### Comments
- Use `///` for documentation comments
- Explain "why" not "what"
- Update comments when code changes

**Example:**
```swift
/// Debounces save operations to reduce disk I/O
/// Wait time: 0.5 seconds
private func scheduleSave() {
    // Implementation
}
```

### Version Control

#### Git Workflow

**Branching Strategy:**
```
main                    # Stable releases
├── develop            # Active development
    ├── feature/xyz    # New features
    ├── bugfix/abc     # Bug fixes
    └── experiment/123 # Experiments
```

**Commit Messages:**
```
<type>: <short summary>

<optional body>

Examples:
- feat: Add note priority feature
- fix: Resolve texture update bug
- refactor: Simplify anchor creation logic
- docs: Update development guide
```

**Before Committing:**
- [ ] Code builds without errors
- [ ] No new warnings
- [ ] Test manually
- [ ] Remove debug print statements
- [ ] Update documentation if needed

### Building for Release

#### Release Checklist

1. **Update Version Number**
   - Target → General → Version
   - Increment appropriately (major.minor.patch)

2. **Update Build Number**
   - Target → General → Build
   - Should increment for each build

3. **Switch to Release Configuration**
   - Edit Scheme → Run → Build Configuration → Release

4. **Clean Build**
   ```
   Product → Clean Build Folder (Shift+Cmd+K)
   Product → Build (Cmd+B)
   ```

5. **Archive**
   ```
   Product → Archive
   ```

6. **Distribute**
   - Window → Organizer
   - Select archive
   - Distribute App
   - Choose distribution method (App Store, TestFlight, etc.)

#### App Store Submission
1. Create app in App Store Connect
2. Fill in metadata (description, screenshots, etc.)
3. Upload build from Organizer
4. Submit for review

## Advanced Topics

### Custom RealityKit Components

Create custom components for specialized behavior:

```swift
struct CustomComponent: Component {
    var customProperty: Float = 0.0
}

// Register component
CustomComponent.registerComponent()

// Use component
entity.components.set(CustomComponent(customProperty: 1.0))
```

### Spatial Anchors

For persistence across sessions:

```swift
// Save anchor
let anchorEntity = AnchorEntity(world: position)
// Store anchor ID and position

// Restore anchor
let restoredAnchor = AnchorEntity(world: savedPosition)
```

### Performance Optimization

**Texture Caching:**
```swift
var textureCache: [UUID: TextureResource] = [:]

func getTexture(for noteID: UUID) -> TextureResource? {
    if let cached = textureCache[noteID] {
        return cached
    }
    // Generate and cache
}
```

**Entity Pooling:**
Reuse entities instead of creating new ones:
```swift
var entityPool: [ModelEntity] = []

func getEntity() -> ModelEntity {
    return entityPool.popLast() ?? ModelEntity()
}

func returnEntity(_ entity: ModelEntity) {
    entityPool.append(entity)
}
```

## Resources

### Apple Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [visionOS Documentation](https://developer.apple.com/documentation/visionos)
- [Swift Documentation](https://www.swift.org/documentation/)

### Sample Code
- [Apple Vision Pro Sample Apps](https://developer.apple.com/visionos/samples/)
- [RealityKit Samples](https://developer.apple.com/augmented-reality/quick-look/)

### Community
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Swift Forums](https://forums.swift.org/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/visionos)

### Learning Resources
- [WWDC Videos](https://developer.apple.com/videos/)
- [Hacking with Swift](https://www.hackingwithswift.com/)
- [RealityKit Tutorial](https://developer.apple.com/documentation/realitykit/creating-a-spatial-drawing-app-with-realitykit)

## Getting Help

### Troubleshooting Steps
1. Check console for error messages
2. Search Apple Developer Forums
3. Review Apple documentation
4. Check this guide for common issues
5. Create a minimal reproduction case
6. File a bug report or ask for help

### Filing Issues
When reporting bugs, include:
- Xcode version
- visionOS version
- Device or simulator
- Steps to reproduce
- Expected vs actual behavior
- Console logs
- Screenshots/screen recordings

## Contributing

### Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push to your fork
7. Create pull request with description

### Code Review Checklist
- [ ] Follows Swift style guide
- [ ] No new warnings
- [ ] Documentation updated
- [ ] Manual testing completed
- [ ] Commit messages are clear
- [ ] No debug code left in
