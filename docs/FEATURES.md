# Features

## Core Features

### 1. Spatial Note Creation and Placement

#### Create Notes in 3D Space
- **Spawn in Front**: Create new notes positioned directly in front of your current view with a single tap
- **Camera-Aware Positioning**: Notes automatically appear at a comfortable distance (2 meters) from your viewpoint
- **Default Orientation**: New notes face toward you for immediate readability

#### Positioning and Movement
- **Free Positioning**: Drag notes anywhere in 3D space using natural hand gestures
- **Real-Time Updates**: Note positions update smoothly as you drag them
- **Persistent Placement**: Notes remember their exact position and orientation in 3D space
- **Tap to Focus**: Tap any note to bring it to the center of your view for easier reading and editing

### 2. Note Categorization System

#### Six Category Types
- **Work**: Professional tasks and work-related notes (Orange)
- **Personal**: Personal reminders and private notes (Blue)
- **Reminder**: Time-sensitive reminders and alerts (Red)
- **Idea**: Creative thoughts and brainstorming (Yellow)
- **Todo**: Action items and task lists (Green)
- **None**: Uncategorized notes (Gray)

#### Visual Organization
- **Color Coding**: Each category has a distinct color for quick visual identification
- **System Icons**: SF Symbols icons provide additional visual categorization
  - Work: briefcase.fill
  - Personal: person.fill
  - Reminder: bell.fill
  - Idea: lightbulb.fill
  - Todo: checkmark.circle.fill
  - None: questionmark.circle.fill
- **Category Filtering**: Filter your note list by category to focus on specific types of notes

### 3. Flexible Note Sizing

#### Three Size Options
- **Small**: 0.3m × 0.192m (12:7.68 aspect ratio) - Perfect for quick reminders
- **Medium**: 0.5m × 0.4m (5:4 aspect ratio) - Default size for general notes
- **Large**: 0.7m × 0.56m (5:4 aspect ratio) - Ideal for detailed content

#### Size Management
- Change note size at any time through the edit interface
- Size changes preserve note content and position
- Visual feedback shows size before confirming

### 4. Immersive Space Control

#### Dual View Modes
- **Window Mode**: Traditional app window with split-pane interface
  - Left side: Scrollable notes list with search and filters
  - Right side: Toolbar with spawn controls
  - Perfect for quick note creation and management

- **Immersive Mode**: Full spatial computing experience
  - Notes rendered as 3D objects in your environment
  - Interact with notes using natural gestures
  - Focus entirely on your spatial workspace

#### Immersion Styles
- **Mixed Immersion**: Blend notes with your physical environment
- **Progressive Immersion**: Gradually increase immersion level
- **Seamless Transitions**: Toggle between modes without losing note positions

### 5. Note Content Management

#### Rich Text Support
- Multi-line text content
- Clean, readable typography
- Support for lengthy notes

#### Edit Interface
- **Quick Edit**: Edit directly on the 3D note panel (coming soon)
- **Edit Sheet**: Dedicated edit interface for focused writing
- **Real-Time Preview**: See changes as you type
- **Auto-Save**: Changes save automatically with smart debouncing

#### Note Operations
- **Create**: Add new notes with default settings
- **Read**: View note content in 3D space or list view
- **Update**: Edit content, category, and size
- **Delete**: Remove notes with confirmation

### 6. Search and Discovery

#### Search Functionality
- **Full-Text Search**: Find notes by searching their content
- **Real-Time Filtering**: Results update as you type
- **Case-Insensitive**: Searches work regardless of capitalization
- **Highlight Matches**: Visual indicators show matching notes

#### Sorting and Organization
- **Sort by Recent**: Most recently updated notes appear first
- **Category Grouping**: View notes organized by category
- **Timestamp Display**: See when notes were created and last modified
- **Note Count**: Track how many notes you have in each category

### 7. Data Persistence

#### Automatic Saving
- **Debounced Auto-Save**: Changes save automatically after 0.5 seconds of inactivity
- **JSON Storage**: Notes stored in device documents directory
- **Crash Recovery**: Notes persist even if the app closes unexpectedly
- **Version Compatibility**: Backward-compatible data format

#### Spatial Data
- **Position Preservation**: Exact 3D coordinates (SIMD3<Float>)
- **Orientation Saving**: Rotation quaternions (simd_quatf)
- **Migration Support**: Handles legacy data formats gracefully

### 8. 3D Rendering and Interaction

#### Visual Rendering
- **SwiftUI Textures**: Notes rendered as textured 3D planes
- **Dynamic Updates**: Textures regenerate when content changes
- **Material Properties**: Realistic surface appearance with metallic and roughness properties
- **Horizontal Orientation**: Notes lay flat like physical cards

#### Gesture Support
- **Drag Gesture**: Move notes by grabbing and dragging
- **Tap Gesture**: Focus notes by tapping them
- **Hover Effects**: Visual feedback when hovering over notes
- **Input Targets**: Notes respond to Vision Pro's eye and hand tracking

#### Performance Optimization
- **Content Hashing**: Only regenerate textures when content actually changes
- **Periodic Updates**: Throttled texture updates (every 10 frames) for performance
- **Immediate Sync**: New notes render instantly
- **Efficient Anchoring**: Minimal overhead for spatial tracking

### 9. User Interface Features

#### Split-Pane Layout (Window Mode)
- **60/40 Split**: 60% notes list, 40% toolbar
- **Responsive Design**: Adapts to different window sizes
- **Clean Spacing**: 20pt padding throughout
- **VisionOS Styling**: Native look and feel

#### Note List View
- **Vertical Scrolling**: Browse all notes easily
- **Card Layout**: Each note displayed as a card with metadata
- **Category Badges**: Visual category indicators on each card
- **Quick Actions**: Edit and view actions accessible from list

#### Toolbar
- **Spawn Control**: Single button to create notes in front of view
- **Immersive Toggle**: Switch between window and immersive modes
- **Status Indicators**: Visual feedback for current mode

### 10. Accessibility Features

#### Visual Accessibility
- **High Contrast Colors**: Category colors chosen for visibility
- **Clear Typography**: Readable font sizes and weights
- **Icon Support**: SF Symbols provide additional context

#### Interaction Accessibility
- **Gesture Alternatives**: Notes accessible via list view or spatial view
- **Forgiving Interactions**: Large tap targets and tolerant gesture recognition
- **Keyboard Support**: All features accessible without gestures (in window mode)

## Feature Highlights by Use Case

### For Quick Capture
1. Open SpatialNotes
2. Tap "Spawn in front"
3. Type your note
4. Done - note persists in space

### For Organization
1. Create multiple notes
2. Drag notes to meaningful locations
3. Color-code with categories
4. Filter by category to focus

### For Immersive Work
1. Toggle immersive mode
2. Arrange notes spatially around you
3. Walk through your information space
4. Tap notes to bring them into focus

### For Quick Reference
1. Use search to find specific notes
2. Sort by recent to see latest updates
3. Check timestamps to know when notes were created
4. Filter by category to see related notes
