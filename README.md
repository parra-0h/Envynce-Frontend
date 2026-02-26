# Config Service Dashboard

A modern, minimalist administrative dashboard developed in Flutter.

## Features
-   User-friendly UI/UX inspired by modern SaaS platforms (Stripe, Vercel).
-   Dashboard overview layout.
-   Configuration management (List, Create, Edit, Delete).
-   Environment filtering.
-   Responsive sidebar navigation.

## Getting Started

### Prerequisites
-   Flutter SDK installed.
-   Dart SDK installed.

### Setup
1.  Navigate to the project directory:
    ```bash
    cd Config-Service
    ```
2.  Install dependencies:
    ```bash
    flutter pub get
    ```

### Running the App

#### Web (Recommended if Linux dependencies are missing)
To run the app in your browser:
```bash
flutter run -d chrome
```

#### Linux Desktop
To run as a native Linux application:
```bash
flutter run -d linux
```
> **Note**: Building for Linux requires additional system dependencies (`clang`, `cmake`, `ninja-build`, `pkg-config`, `libgtk-3-dev`). If you encounter linker errors, please ensure these packages are installed.

## Project Structure
-   `lib/main.dart`: Entry point.
-   `lib/theme/`: Theme configuration (Colors, Typography).
-   `lib/layout/`: Main layout widgets (Sidebar, Topbar).
-   `lib/views/`: Screen views (Configurations, Dashboard).
-   `lib/widgets/`: Reusable components (Modals, Custom Buttons).
-   `lib/models/`: Data models.
