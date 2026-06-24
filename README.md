# ZTxtEditor

A mobile code/text editor built with Flutter. Open, edit, and save files directly on your device with syntax highlighting and a dev-duck background overlay.

## Features

### Editor

- Syntax highlighting for **HTML, CSS, JavaScript, Markdown, Python, plain text**
- Line numbers
- Unsaved-changes indicator (`•` in the title bar)
- Save / Save As (writes to the device's documents directory on mobile, native dialog on desktop)
- Confirmation dialog on close when there are unsaved changes

### Duck overlay

A rubber duck is rendered as a semi-transparent background on every page — because every developer needs one.

| Mode         | Behavior                                                        |
| ------------ | --------------------------------------------------------------- |
| Full random  | A new duck image is fetched on each navigation                  |
| Fixed random | Fetch once from the API and keep the same image until refreshed |
| Disabled     | No duck, opacity controls are hidden                            |

### Settings

- Background color picker
- Duck overlay mode selection
- Duck opacity slider (1–100 %)
- "New duck" button (fixed-random mode)

## Project structure

```text
lib/
├── main.dart                  # App entry point
├── routing.dart               # GoRouter config
├── states/
│   └── settings.dart          # AppSettings singleton (ChangeNotifier + SharedPreferences)
├── layouts/
│   └── appLayout/main.dart    # Shell layout with duck overlay
├── views/
│   ├── home/main.dart
│   ├── editor/main.dart       # File open / edit / save logic
│   ├── projects/main.dart
│   └── settings/main.dart
└── widgets/
    ├── code_editor.dart        # Syntax-highlighted editor
    ├── duck_overlay.dart       # Duck background widget
    ├── cached_duck_image.dart  # Image fetch + opacity wrapper
    ├── color_picker.dart
    └── z_app_bar.dart
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires Flutter SDK `^3.12.0`.

## Dependencies

| Package                           | Purpose                               |
| --------------------------------- | ------------------------------------- |
| `go_router`                       | Navigation                            |
| `file_picker`                     | Open / save file dialogs              |
| `flutter_highlight` / `highlight` | Syntax highlighting                   |
| `shared_preferences`              | Persist settings                      |
| `path_provider`                   | Resolve documents directory on mobile |
| `dio`                             | HTTP client (duck API)                |
| `flutter_colorpicker`             | Background color picker               |
