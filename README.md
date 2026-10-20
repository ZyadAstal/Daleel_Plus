# Daleel Plus (+ دليل) 📚

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
- **Cairo**, added locally in `assets/fonts/` (no `google_fonts` package).

---

## 🛠️ Tech Stack
- **Framework:** Flutter
- **State Management & Navigation:** GetX 
- **Backend:** Firebase

| Package              | Purpose                                          |
|----------------------|--------------------------------------------------|
| `get`                | State management, routing, dependency injection  |
| `shared_preferences` | Simple settings (login state, onboarding seen)   |
| `hive` / `hive_flutter` | Local storage and caching                     |
| `firebase_core`      | Firebase initialization                          |
| `firebase_auth`      | User authentication                              |
| `cloud_firestore`    | Database                                         |

---

## 📁 Project Structure

```
lib/
├── main.dart
├── core/                      # Shared settings for the whole app
│   ├── constants/             # app_colors, app_sizes, app_strings
│   └── theme/                 # app_theme, app_text_styles
│
├── data/                      # Talking to Firebase / Hive
│   ├── models/                # Data classes + fromJson / toJson
│   └── repositories/          # Read & write data (one file per feature)
│
├── domain/                    # (optional) Business logic shared between features
│
└── presentation/              # Everything the user sees
    ├── features/              # One folder per feature
    │   ├── academic/
    │   ├── admin/
    │   ├── app_status/
    │   ├── auth/
    │   ├── bookings/
    │   ├── discovery/
    │   ├── onboarding/
    │   ├── printing/
    │   ├── profile/
    │   ├── providers/
    │   │   ├── screens/       # The screens of this feature
    │   │   ├── state/         # GetX controllers
    │   │   └── widgets/       # Widgets used only inside this feature
    │   └── support/
    │
    └── shared/
        └── widgets/           # Custom widgets used by all features
```

### Every feature has the same 3 folders

| Folder     | What goes inside                                       |
|------------|--------------------------------------------------------|
| `screens/` | Screen files, e.g. `provider_dashboard_screen.dart`    |
| `state/`   | GetX controller, e.g. `provider_dashboard_controller.dart` |
| `widgets/` | Small widgets used **only** in this feature            |

### Simple flow
```
Screen  →  Controller (state)  →  Repository (data)  →  Firebase / Hive
```
The screen shows data, the controller holds it, and the repository brings it.

---

## 🧩 Shared Widgets
All in `presentation/shared/widgets/`. Import them all with one line:
```dart
import 'package:daleel_plus/presentation/shared/widgets/widgets.dart';
```

| Widget              | Use                                               |
|---------------------|---------------------------------------------------|
| `AppAppBar`         | Screen title bar                                  |
| `AppButton`         | Main button (filled / outlined / loading)         |
| `AppTextField`      | Input with label (supports password)              |
| `AppDropdown`       | Select from a list                                |
| `AppSearchBar`      | Search field                                      |
| `AppCard`           | White rounded card                                |
| `AppNetworkImage`   | Image from URL with placeholder                   |
| `AppSectionHeader`  | Section title + "See all"                         |
| `AppStatusChip`     | Status: pending / accepted / rejected / completed |
| `AppStepIndicator`  | Steps progress (e.g. Add Service 1 of 3)          |
| `AppRating`         | Star + rating number                              |
| `AppLoading`        | Loading indicator                                 |
| `AppEmptyState`     | "No data" view                                    |
| `AppErrorState`     | Error view with retry                             |
| `AppDialogs`        | Success / error snackbar, confirm dialog          |

**Example:**
```dart
Scaffold(
  appBar: const AppAppBar(title: 'إضافة خدمة'),
  body: Column(
    children: [
      const AppStepIndicator(currentStep: 1, totalSteps: 3),
      const AppTextField(label: 'اسم الخدمة', hint: 'اكتب اسم الخدمة'),
      AppButton(text: 'التالي', onPressed: () {}),
    ],
  ),
);
```

---

## 👥 Team Rules
- Each member works **only inside their own feature folder**.
- Each member builds the **backend of their own feature** (model + repository + controller).
- Need a widget in more than one feature? Ask to add it to `shared/widgets/` instead of copying it.
- Don't change files in `core/` or `shared/` without telling the team.
  
---

## ✍️ Code Guidelines
- Keep code **simple and readable**.
- Use `AppColors`, `AppSizes`, and `AppTextStyles` only; no hard-coded colors or sizes.
- File names use `snake_case` (e.g. `provider_dashboard_screen.dart`).
- Class names use `PascalCase` (e.g. `ProviderDashboardScreen`).

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
4. **Run the app**
   ```bash
   flutter run
   ```
