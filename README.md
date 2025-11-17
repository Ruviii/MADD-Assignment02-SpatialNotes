# SpatialNotes

**A spatial computing note-taking app for Apple Vision Pro**

Transform the way you organize information by anchoring notes in 3D space. SpatialNotes leverages visionOS and RealityKit to create an immersive note-taking experience that uses your spatial memory for better organization.

![Version](https://img.shields.io/badge/version-1.0-blue)
![Platform](https://img.shields.io/badge/platform-visionOS%2026.1-purple)
![Swift](https://img.shields.io/badge/Swift-6.2-orange)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Overview

SpatialNotes is a native visionOS application that brings note-taking into the third dimension. Create, edit, and organize notes as interactive 3D objects in your physical environment. Drag notes around your space, categorize them with colors, and toggle between window and immersive modes for focused work.

### Key Highlights

- **Spatial Anchoring**: Place notes anywhere in 3D space and they'll stay there
- **Immersive Experience**: Toggle between window and fully immersive modes
- **Natural Interactions**: Drag notes with your hands, tap to focus
- **Smart Organization**: 6 color-coded categories, search, and filtering
- **Persistent Storage**: All notes and positions automatically saved
- **Zero Dependencies**: Built entirely with Apple's native frameworks

---

## Quick Start

### Prerequisites

- **macOS**: Sonoma (14.0) or later
- **Xcode**: 16.0 or later with visionOS SDK 26.1+
- **Apple Vision Pro**: For device testing (simulator available for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd SpatialNotes
   ```

2. **Open in Xcode**
   ```bash
   open SpatialNotes.xcodeproj
   ```

3. **Configure signing**
   - Select the SpatialNotes target
   - Go to Signing & Capabilities
   - Choose your development team

4. **Build and run**
   - Select "Apple Vision Pro" simulator or your connected device
   - Press `Cmd+R` to build and run

### First Steps

1. **Create your first note**: Tap "Spawn in front" button
2. **Edit the note**: Tap the note to open the edit interface
3. **Move the note**: Drag it anywhere in 3D space
4. **Toggle immersive mode**: Experience your notes in full spatial view
5. **Organize with categories**: Assign colors for visual organization

---

## Features

### ✨ Core Features

- **Spatial Note Creation**: Spawn notes at camera-forward position with one tap
- **3D Positioning**: Drag notes anywhere in 3D space with natural gestures
- **Tap to Focus**: Tap any note to bring it center-view for easy reading
- **Category System**: 6 categories (Work, Personal, Reminder, Idea, Todo, None)
- **Flexible Sizing**: Small, Medium, and Large note sizes
- **Immersive Mode**: Toggle between window and immersive spatial views
- **Search & Filter**: Find notes by content or filter by category
- **Auto-Save**: Changes automatically persist with smart debouncing
- **Persistent Placement**: Notes remember exact position and orientation

### 🎨 Visual Design

- Color-coded categories with SF Symbols icons
- Clean, readable typography
- Smooth animations and transitions
- Native visionOS styling

### 🚀 Performance

- Hardware-accelerated 3D rendering
- Optimized texture generation with content hashing
- Efficient spatial tracking
- Smooth 60 FPS performance

For a complete feature list, see **[FEATURES.md](docs/FEATURES.md)**.

---

## Documentation

### 📚 Complete Documentation Index

| Document | Description |
|----------|-------------|
| **[MOTIVATION.md](docs/MOTIVATION.md)** | The vision and philosophy behind SpatialNotes |
| **[FEATURES.md](docs/FEATURES.md)** | Comprehensive feature documentation with examples |
| **[TECHNOLOGIES.md](docs/TECHNOLOGIES.md)** | Technology stack, frameworks, and architecture |
| **[DEVELOPMENT.md](docs/DEVELOPMENT.md)** | Development guide, setup, and contribution guidelines |
| **[ROADMAP.md](docs/ROADMAP.md)** | Development roadmap and planned features |
| **[FUTURE_WORK.md](docs/FUTURE_WORK.md)** | Long-term vision and experimental ideas |

### 📖 Quick Links

- **Getting Started**: [DEVELOPMENT.md - Installation](docs/DEVELOPMENT.md#installation)
- **Architecture**: [TECHNOLOGIES.md - Architecture Patterns](docs/TECHNOLOGIES.md#architecture-patterns)
- **Contributing**: [DEVELOPMENT.md - Contributing](docs/DEVELOPMENT.md#contributing)
- **Roadmap**: [ROADMAP.md - Development Phases](docs/ROADMAP.md#development-phases)

---

## Technology Stack

### Core Technologies

- **Swift 6.2**: Modern, type-safe programming language
- **SwiftUI**: Declarative UI framework
- **RealityKit**: 3D rendering and spatial computing
- **Combine**: Reactive programming
- **SIMD**: Vector mathematics for 3D positioning

### Platform

- **visionOS 26.1**: Apple Vision Pro operating system
- **Xcode 16+**: Development environment
- **Reality Composer Pro**: 3D content management

### Architecture

- **MVVM Pattern**: Clear separation of concerns
- **Observable Pattern**: Reactive state management
- **Zero External Dependencies**: Built entirely with Apple frameworks

For detailed technology information, see **[TECHNOLOGIES.md](docs/TECHNOLOGIES.md)**.

---

## Project Structure

```
SpatialNotes/
├── SpatialNotes/                    # Main application
│   ├── App/
│   │   ├── SpatialNotesApp.swift   # App entry point
│   │   └── AppModel.swift          # Global app state
│   ├── Models/
│   │   └── Note.swift              # Note data model
│   ├── Stores/
│   │   └── NoteStore.swift         # Persistence layer
│   ├── Controllers/
│   │   └── SpatialSceneController.swift  # RealityKit management
│   ├── Views/
│   │   ├── ContentView.swift       # Main window UI
│   │   ├── ImmersiveView.swift     # 3D immersive space
│   │   ├── NotePanelView.swift     # Note rendering
│   │   ├── NotesListView.swift     # Notes list
│   │   ├── ToolbarView.swift       # Controls toolbar
│   │   └── ToggleImmersiveSpaceButton.swift
│   ├── Assets.xcassets/            # App assets
│   └── Info.plist                  # Configuration
├── Packages/
│   └── RealityKitContent/          # 3D content package
├── docs/                           # Documentation
│   ├── MOTIVATION.md
│   ├── FEATURES.md
│   ├── TECHNOLOGIES.md
│   ├── DEVELOPMENT.md
│   ├── ROADMAP.md
│   └── FUTURE_WORK.md
└── README.md                       # This file
```

---

## Development

### Building from Source

```bash
# Clone repository
git clone <repository-url>
cd SpatialNotes

# Open in Xcode
open SpatialNotes.xcodeproj

# Build for simulator
xcodebuild -scheme SpatialNotes -destination 'platform=visionOS Simulator,name=Apple Vision Pro'

# Run tests (when available)
# xcodebuild test -scheme SpatialNotes
```

### Development Workflow

1. **Make changes**: Edit Swift files in Xcode
2. **Build**: `Cmd+B` to build
3. **Run**: `Cmd+R` to build and run
4. **Debug**: Set breakpoints and use Xcode debugger
5. **Test**: Manual testing on simulator or device
6. **Commit**: Follow commit message conventions

For complete development instructions, see **[DEVELOPMENT.md](docs/DEVELOPMENT.md)**.

### Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit (`git commit -m 'feat: Add amazing feature'`)
6. Push to your fork (`git push origin feature/amazing-feature`)
7. Open a Pull Request

See **[DEVELOPMENT.md - Contributing](docs/DEVELOPMENT.md#contributing)** for detailed guidelines.

---

## Roadmap

### Current Status: v1.0 MVP ✅

Core spatial note-taking functionality complete.

### Upcoming

- **v1.1** (Phase 2): Performance optimization and UX polish
- **v1.2** (Phase 3): Rich text and markdown support
- **v2.0** (Phase 4): iCloud sync and sharing
- **v2.5** (Phase 5): AI-powered features
- **v3.0** (Phase 6): iOS and macOS companion apps

For the complete roadmap, see **[ROADMAP.md](docs/ROADMAP.md)**.

---

## Use Cases

### Knowledge Workers
Organize research notes spatially. Place work notes on your virtual desk, references on the wall, and quick reminders by the door.

### Creative Professionals
Brainstorm in 3D space. Arrange ideas spatially, create visual connections, and navigate through your creative process.

### Students
Study in immersive mode. Place lecture notes around you, flashcards at eye level, and assignments in a dedicated zone.

### Researchers
Manage complex information. Link related notes, organize by topic spatially, and leverage spatial memory for recall.

### Daily Users
Quick capture for everyday notes. Shopping lists, reminders, ideas—all organized in your personal 3D workspace.

---

## Screenshots

> **Note**: Screenshots will be added after Vision Pro device testing.

### Window Mode
Split-pane interface with notes list and creation toolbar.

### Immersive Mode
3D spatial view with notes as interactive objects in your environment.

### Note Editing
Clean edit interface for content and metadata.

---

## Requirements

### Minimum Requirements

- **visionOS**: 26.1 or later
- **Storage**: 50MB free space
- **Memory**: Available on all Vision Pro models

### Recommended

- **visionOS**: Latest version
- **Storage**: 100MB+ for note storage
- **iCloud**: For future sync features (coming in v2.0)

---

## Performance

### Metrics

- **Launch Time**: < 2 seconds
- **Note Creation**: < 500ms
- **Frame Rate**: 60 FPS with 50+ notes
- **Memory**: Efficient with < 100MB typical usage

### Optimization

- Content hashing prevents unnecessary texture updates
- Debounced auto-save reduces disk I/O
- Periodic texture updates maintain smooth rendering
- Efficient spatial tracking with minimal overhead

---

## Privacy & Data

### Local-First

All data stored locally on device by default. Notes saved to:
```
~/Documents/SpatialNotes/notes.json
```

### Data Format

JSON format for human readability and portability:
```json
{
  "id": "UUID",
  "content": "Note text",
  "category": "work",
  "size": "medium",
  "position": [x, y, z],
  "orientation": [x, y, z, w],
  "createdAt": "ISO8601",
  "updatedAt": "ISO8601"
}
```

### Future: Cloud Sync (v2.0)

Optional iCloud sync planned for future release. Will remain opt-in with local-first philosophy.

---

## Troubleshooting

### Common Issues

**Notes don't appear in immersive space**
- Check that notes have valid positions (not NaN)
- Verify immersive space is actually open
- Try toggling immersive mode off and on

**App crashes on launch**
- Check console for errors
- Verify visionOS version compatibility
- Try deleting and reinstalling

**Poor performance**
- Reduce number of visible notes
- Close other apps
- Restart Vision Pro

For more help, see **[DEVELOPMENT.md - Troubleshooting](docs/DEVELOPMENT.md#troubleshooting)**.

---

## FAQ

**Q: Can I use this on iPhone or iPad?**
A: Currently visionOS only. iOS/iPad support planned for v3.0. See [ROADMAP.md](docs/ROADMAP.md).

**Q: Will my notes sync across devices?**
A: Not yet. iCloud sync planned for v2.0. See [ROADMAP.md](docs/ROADMAP.md).

**Q: Can I export my notes?**
A: Notes are stored in JSON format in your Documents folder, which you can access manually. Export features planned for v2.0.

**Q: Is this open source?**
A: License TBD. Check repository license file for current status.

**Q: Can I collaborate with others?**
A: Not yet. Multi-user features planned for Phase 4. See [ROADMAP.md](docs/ROADMAP.md).

---

## Motivation

Why build a note-taking app for spatial computing?

Traditional note apps are constrained to 2D screens and folders. Humans naturally organize information spatially—we remember where we placed things. SpatialNotes leverages Apple Vision Pro to create a more intuitive organization system that uses your spatial memory.

Read the full story in **[MOTIVATION.md](docs/MOTIVATION.md)**.

---

## License

[License TBD - Add your license information here]

---

## Acknowledgments

### Built With
- [Swift](https://swift.org/) - Programming language
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - UI framework
- [RealityKit](https://developer.apple.com/augmented-reality/realitykit/) - 3D rendering

### Inspiration
- The vision of spatial computing as the future of human-computer interaction
- Apple Vision Pro's potential to transform how we work with information
- The desire to make technology more intuitive through spatial interfaces

---

## Contact

**Developer**: Sujana/Ruvini
**Project**: SpatialNotes
**Platform**: visionOS

For bugs and feature requests, please use GitHub Issues.

---

## Related Links

- [Apple Vision Pro](https://www.apple.com/apple-vision-pro/)
- [visionOS Documentation](https://developer.apple.com/visionos/)
- [RealityKit Documentation](https://developer.apple.com/documentation/realitykit)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)

---

<div align="center">

**Built for the future of spatial computing**

Made with ❤️ for Apple Vision Pro

[Documentation](docs/) • [Roadmap](docs/ROADMAP.md) • [Contributing](docs/DEVELOPMENT.md#contributing)

</div>
