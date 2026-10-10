# Daleel+ Flutter Development Guidelines

This document provides concise, practical guidelines for the Daleel+ Flutter application foundation.

---

## 1. Feature-Based Folder Organization

```
lib/
├── main.dart                      # Application bootstrap & entry point
├── app/                           # Core application infrastructure
│   ├── app.dart                   # MaterialApp root widget
│   ├── app_router.dart            # Centralized route definitions & generator
│   └── app_theme.dart             # Shared Material 3 theme & color tokens
├── screens/                       # Feature screen directories (screens added per task)
│   ├── auth/                      # Authentication (login, register, account type)
│   ├── profile/                   # Profile setup and user preferences
│   ├── discovery/                 # Service and place discovery feed
│   ├── search/                    # Keyword search & filtering
│   ├── education/                 # Education and course listings
│   ├── libraries/                 # Library and printing listings
│   ├── jobs/                      # Jobs and training opportunity listings
│   ├── tutors/                    # Private tutor listings
│   └── notifications/             # In-app notification center
├── widgets/                       # Reusable UI components (added as shared needs arise)
├── models/                        # Domain entities and data models
└── services/                      # API clients and local services
```

---

## 2. Naming Conventions

- **Files:** `snake_case.dart` (e.g., `login_screen.dart`).
- **Classes & Widgets:** `PascalCase` (e.g., `LoginScreen`).
- **Variables & Functions:** `camelCase` (e.g., `userEmail`, `submitForm()`).
- **Constants:** `camelCase` (e.g., `static const String login = '/login'`).
- **Imports:** Prefer package imports (`package:daleel_plus/...`) or clean relative imports.

---

## 3. How to Create and Connect a New Screen

When starting your assigned screen:

1. **Create your screen file** in the relevant feature directory under `lib/screens/`:
   ```dart
   // lib/screens/auth/login_screen.dart
   import 'package:flutter/material.dart';

   class LoginScreen extends StatelessWidget {
     const LoginScreen({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Login')),
         body: const Center(child: Text('Login Content')),
       );
     }
   }
   ```

2. **Connect the screen to `AppRouter`** in `lib/app/app_router.dart`:
   - Import your screen file.
   - Update its route case in `AppRouter.onGenerateRoute`:
     ```dart
     case AppRoutes.login:
       return MaterialPageRoute<void>(
         settings: settings,
         builder: (_) => const LoginScreen(),
       );
     ```

3. **Navigate to the route** using named navigation:
   ```dart
   Navigator.of(context).pushNamed(AppRoutes.login);
   ```

---

## 4. Coordinating Shared Routing and Theme Changes

- **Route Constants:** All route name strings are centralized in `AppRoutes`. Do not hardcode route strings across screens.
- **Theme Usage:** Access styling through `Theme.of(context).colorScheme` or tokens from `AppTheme`. Avoid hardcoding hex colors.
- **Shared Files:** Coordinate with teammates before modifying `app_router.dart`, `app_theme.dart`, or `pubspec.yaml` to prevent merge conflicts.

---

## 5. Development Quality Commands

Run these commands locally before opening a Pull Request:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Format Dart code
dart format lib/ test/

# 3. Static code analysis (must have 0 errors and 0 warnings)
flutter analyze

# 4. Run automated test suite
flutter test

# 5. Build verification
flutter build bundle
```

---

## 6. Git Branch & Pull Request Workflow

1. Create a focused feature branch from `main`:
   ```bash
   git checkout -b feature/task-name
   ```
2. Make atomic, descriptive commits containing only your task files.
3. Ensure `flutter analyze` and `flutter test` pass with zero issues.
4. Open a Pull Request for review. Avoid mixing formatting changes of unrelated files into feature PRs.
