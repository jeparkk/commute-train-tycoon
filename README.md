# Commute Train Tycoon

Flutter MVP for a simple idle train game where players earn gold, upgrade a train cabin, and buy decorations that are automatically placed in fixed slots.

## Current MVP

- Gold increases every second.
- Seat and kiosk slots can be upgraded with gold.
- Decoration management supports buying, fixed-slot placement, and upgrades.
- Offline reward calculation is implemented with local persistence.
- A temporary move reward stub is available from the bottom navigation.

## Recommended Local Path

Use an ASCII-only path for Android/Gradle stability on Windows:

```powershell
C:\Projects\commute_train_tycoon
```

The old OneDrive path can remain as a backup, but active development should happen in this folder.

## Run

```powershell
& "C:\src\flutter\bin\flutter.bat" pub get
& "C:\src\flutter\bin\flutter.bat" run
```

## Validate

```powershell
& "C:\src\flutter\bin\dart.bat" analyze
& "C:\src\flutter\bin\flutter.bat" test
& "C:\src\flutter\bin\flutter.bat" build apk --debug
```

## Code Layout

```text
lib/
  main.dart
  src/
    app.dart
    features/
      game/
        models/
        screens/
        services/
        widgets/
```

## Next Suggested Step

Step 2: improve the current screen into a cuter 2D train-game UI while keeping the fixed-slot interaction model.
