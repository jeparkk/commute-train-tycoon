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
    core/
      assets/
      widgets/
    app.dart
    features/
      game/
        models/
        screens/
        services/
        widgets/
```

## Asset Pipeline

Image paths are registered in `lib/src/core/assets/game_asset.dart`.

The app currently uses icon fallbacks, so it still runs without final PNG assets. To replace a fallback:

1. Add a transparent PNG to `assets/images/...`.
2. Match the file path registered in `GameAssets`.
3. Change that asset entry's `available` value to `true`.

See `assets/images/README.md` for file naming examples.

## Balance Data

Cost, income, appeal, starting gold, and growth curves are defined in:

```text
lib/src/features/game/data/balance_config.dart
```

Adjust that file when tuning early progression.

## Next Suggested Step

Step 5: improve the offline reward popup and settlement experience.
