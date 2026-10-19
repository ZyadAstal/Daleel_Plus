# Daleel Plus (دليل) 📚
**Daleel Plus** is a mobile app that helps students find the services they need in one place: service providers, offers, libraries, and printing centers. Students can browse services, see details, and make bookings, while service providers manage their services, offers, and student requests from their own dashboard.
---

## 🎨 Design
- **Figma:** [Daleel – Figma Design](https://www.figma.com/design/pViEyMFO9HYmySjzX3Xub4/Daleel-?node-id=226-2316&t=VVNaeQLfsNg0H7kA-1)

### Colors
| Name             | Hex       | Usage                        |
|------------------|-----------|------------------------------|
| `primary`        | `#431FC0` | Main buttons, app bar, links |
| `secondary`      | `#FFB020` | Highlights, badges, ratings  |
| `scaffoldBg`     | `#FAF9FF` | Screen background            |
| `surfaceSubdued` | `#F1F3FF` | Cards, input fields          |

### Font
- **Cairo** (supports Arabic and English)

---

## 🛠️ Tech Stack
- **Framework:** Flutter
- **State Management & Navigation:** GetX
- **Backend:** Firebase

### Main Packages
| Package              | Purpose                                 |
|----------------------|-----------------------------------------|
| `get`                | State management, routing, dependency injection |
| `shared_preferences` | Saving simple settings (e.g. login state, language) |
| `hive` / `hive_flutter` | Local storage and caching            |
| `firebase_core`      | Firebase initialization                 |
| `firebase_auth`      | User authentication                     |
| `cloud_firestore`    | Database (services, offers, bookings)   |

---

## 📁 Project Structure
```
Daleel_Plus/
├── docs/
│   └── authentication-integration-guide.md   # How authentication is connected
├── lib/
│   ├── main.dart
│   ├── core/                     # (to be added)
│   │   ├── constants/            # App colors, strings, sizes
│   │   ├── theme/                # App theme (colors + Cairo font)
│   │   ├── routes/               # GetX routes (app_pages, app_routes)
│   │   └── widgets/              # Shared widgets (buttons, text fields, cards)
│   ├── models/
│   │   ├── auth_models.dart      # Authentication data models
│   │   └── auth_result.dart      # Result of auth requests (success / error)
│   ├── services/
│   │   ├── api_config.dart       # API settings (base URL, endpoints)
│   │   ├── auth_service.dart     # Real authentication service
│   │   └── mock_auth_service.dart # Fake auth service for testing without a server
│   └── screens/                  # (to be added)
│       ├── provider/             # Service provider screens
│       └── printing/             # Libraries & printing screens
├── test/
├── pubspec.yaml
└── README.md
```
> **Note:** Folders marked *(to be added)* are not created yet. They will be added as the screens are built.

### Documentation
- [`docs/authentication-integration-guide.md`](docs/authentication-integration-guide.md): explains how authentication works in the app.

---

## 🚀 Getting Started
1. **Clone the project**
   ```bash
   git clone <repo-url>
   cd Daleel_Plus
   ```

2. **Install packages**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This creates `firebase_options.dart` and connects the app to your Firebase project.

4. **Run the app**
   ```bash
   flutter run
   ```

---

## ✍️ Code Guidelines
- Keep code **simple and readable**.
- Use the colors from `core/constants/app_colors.dart` only; no hard-coded colors.
- Put any widget used in more than one screen inside `core/widgets/`.
- Each screen has its own controller (GetX) when it needs state.
- File names use `snake_case` (e.g. `provider_dashboard_screen.dart`).
---
