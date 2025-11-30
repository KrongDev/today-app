# Today - Flutter Client

A hybrid schedule management app with offline-first architecture.

## Features

- ✅ **Offline-First**: Full functionality without internet connection
- ✅ **Clean Architecture**: Feature-first structure with clear separation of concerns
- ✅ **Reactive UI**: Real-time updates with Riverpod + Isar streams
- ✅ **Calendar Management**: Day/Week/Month views with schedule CRUD
- ✅ **Theme Support**: Light/Dark/System themes
- ✅ **Settings**: User preferences with persistent storage
- 🔄 **API Integration**: Ready for backend sync (currently offline-only)

## Getting Started

### Prerequisites

- Flutter SDK 3.2.0+
- Dart SDK 3.2.0+

### Installation

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

## Architecture

This project follows **Clean Architecture** with a **Feature-First** structure:

```
lib/
├── core/           # Shared utilities, config, network, storage
├── features/       # Feature modules (auth, schedule, settings)
│   └── [feature]/
│       ├── data/       # DTOs, DataSources, Repositories
│       ├── domain/     # Entities, UseCases, Interfaces
│       └── presentation/ # Providers, Screens, Widgets
└── main.dart
```

### Key Technologies

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Database**: Isar
- **Networking**: Dio
- **Code Generation**: Freezed, JSON Serializable
- **Functional Programming**: FpDart

## Project Structure

See [Walkthrough](../../.gemini/antigravity/brain/52d9ec02-041e-4ad4-be4e-5fc18b2fb442/walkthrough.md) for detailed architecture documentation.

## Development

### Code Generation

```bash
# Watch mode (auto-regenerate on save)
flutter pub run build_runner watch

# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Linting

```bash
flutter analyze
```

### Testing

```bash
flutter test
```

## Build

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
flutter build ios --release
```

## Documentation

- [Build Instructions](../../.gemini/antigravity/brain/52d9ec02-041e-4ad4-be4e-5fc18b2fb442/build_instructions.md)
- [Walkthrough](../../.gemini/antigravity/brain/52d9ec02-041e-4ad4-be4e-5fc18b2fb442/walkthrough.md)
- [System Architecture](../docs/3_system_architecture.md)
- [API Specification](../docs/4_api_specification.md)

## License

Copyright © 2025 Today App
