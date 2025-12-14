# Rumour - Anonymous Room Code Chat App

Rumour is a Flutter-based realtime chat application that allows users to join or create anonymous chat rooms using unique 6-digit codes. It features random identity generation, local persistence, dark/light mode, and seamless offline support.

## 📥 Submission & Demo

*   **📱 Download APK**: [app-release.apk](/submission/app-release.apk) (Located in `submission/` folder)
*   **▶️ Watch Demo**: [Video Demonstration](/submission/rumour%20app%20demonstration.mov) (Located in `submission/` folder)

## 🎥 Video Demo Highlights

This submission demonstrates adherence to Figma designs with enhanced UX and bonus features:

### 1. Onboarding & Room Management
*   **Room Creation & Joining**: Generate unique codes or join existing rooms with real-time member count updates.
*   **Identity**: Random identities fetched from **Random User API**. Aliases (e.g., "Wayne Holt") persist locally per room, so returning users are recognized.

### 2. Chat Interface
*   **Real-time**: Instant sync via Firestore with server timestamps and date separators.
*   **Pagination**: Efficiently loads 25 messages at a time; scrolls to fetch history.
*   **UI Polish**: Replaced low-quality assets with native Flutter icons (e.g., Send button) for sharpness.

### 3. Offline Capabilities
*   **Persistence**: Chats remain visible even after closing the app.
*   **Auto-Sync**: Messages sent while offline are queued and sent automatically upon reconnection.

### 4. Bonus Features
*   **Theme Toggle**: Fully supported Light/Dark mode.
*   **Animations**: Added custom entrance and loading animations.
*   **UX**: Added "Create one" flow for users without codes.

### ⚠️ Technical Notes
*   **Notifications**: App requests permissions, but upstream triggers require Firebase Blaze plan (Cloud Functions) which is not active here.
*   **Stability**: Robust error handling ensures the app doesn't crash on network or token errors in release mode.

## Codebase Structure

The project follows a standard Flutter feature-based architecture within the `lib/` directory:

```
lib/
├── models/             # Data models
│   └── message.dart    # Chat message model
├── screens/            # UI Screens
│   ├── name_generation_screen.dart # Identity reveal & animation
│   └── room_screen.dart            # Main chat interface
├── services/           # Business Logic & External Services
│   ├── chat_service.dart           # Firestore chat operations
│   ├── identity_service.dart       # Random identity generation & local storage
│   ├── notification_service.dart   # Push notification handling
│   ├── presence_service.dart       # Realtime user presence tracking
│   ├── room_service.dart           # Room creation/joining logic
│   └── theme_service.dart          # Theme state management
├── theme/              # Styling
│   ├── app_colors.dart             # Color palette tokens
│   └── app_theme.dart              # ThemeData definitions (Light/Dark)
├── widgets/            # Reusable UI Components
│   ├── app_card.dart               # Theme-aware card wrapper
│   ├── chat_bubble.dart            # Message bubble widget
│   ├── room_app_bar.dart           # Custom AppBar for rooms
│   └── room_code_input.dart        # 6-digit input field
├── firebase_options.dart # Firebase configuration
└── main.dart           # Entry point, App Wiring, Welcome Screen
```

## Firebase Cloud Firestore Data Structure

The application uses Cloud Firestore for realtime data sync. The database structure is designed for scalability and simple room-based isolation.

### Top-level Collections

#### `rooms` (Collection)
Stores metadata for each active chat room.
*   **Document ID**: Auto-generated or custom.
*   **Fields**:
    *   `code`: `string` (Unique 6-digit room code, e.g., "123456")
    *   `createdAt`: `timestamp`
    *   `lastActive`: `timestamp`

#### `rooms/{roomId}/messages` (Sub-collection)
Stores all chat messages for a specific room.
*   **Document ID**: Auto-generated.
*   **Fields**:
    *   `text`: `string` (Message content)
    *   `senderId`: `string` (Unique handle or ID of the sender)
    *   `senderHandle`: `string` (User's handle, e.g., "@BraveBadger")
    *   `displayName`: `string` (User's display name, e.g., "Brave Badger")
    *   `timestamp`: `timestamp` (Server timestamp)

#### `rooms/{roomId}/presence` (Sub-collection)
Tracks active users in a room (for "X members online" count).
*   **Document ID**: User's handle or unique ID.
*   **Fields**:
    *   `handle`: `string`
    *   `lastSeen`: `timestamp`
    *   `joinedAt`: `timestamp`