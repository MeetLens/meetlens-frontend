# MeetLens

MeetLens is a Flutter application designed for real-time audio capturing and analysis. It leverages the power of Flutter for cross-platform support and integrates with backend services via WebSockets for efficient data streaming.

## Features

- **Real-time Audio Recording**: Captures high-quality audio directly from the device's microphone.
- **Audio Streaming**: Streams captured audio data in real-time using WebSockets.
- **Permission Handling**: Seamlessly manages microphone permissions to ensure a smooth user experience.
- **State Management**: Utilizes `flutter_riverpod` for robust and scalable state management.

## Tech Stack

- **Flutter**: UI toolkit for building natively compiled applications.
- **Dart**: Programming language optimized for UI development.
- **Riverpod**: A reactive caching and data-binding framework.
- **WebSockets**: For real-time bi-directional communication.

## Getting Started

This project is a starting point for a Flutter application.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
- An IDE (VS Code, Android Studio, or IntelliJ) with Flutter plugins installed.

### Installation

1.  **Clone the repository:**

    ```bash
    git clone <repository-url>
    cd meetlens-frontend
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

### Running the App

To run the application on a connected device or emulator:

```bash
flutter run
```

For more help with getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Project Structure

- `lib/`: Contains the main source code.
  - `main.dart`: Entry point of the application.
  - `screens/`: UI screens (e.g., `home_screen.dart`).
  - `services/`: Business logic and services (e.g., `audio_service.dart`).
- `pubspec.yaml`: Project configuration and dependencies.
