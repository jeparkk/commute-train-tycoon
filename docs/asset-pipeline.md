# 2D Art Asset Pipeline

This project currently uses Flutter custom painters as temporary game art. Final art can replace those painters gradually through PNG assets registered in `lib/src/core/assets/game_asset.dart`.

The current art/UI direction and main screen target mockup are documented in `docs/step16-art-ui-direction.md`.

## Style Target

- Soft pixel-inspired 2D illustration
- Clear dark outline
- Simple readable shapes for small mobile screens
- Warm train cabin lighting
- Accent colors: teal, yellow, mint, coral, cream
- Transparent background for characters, objects, and decorations
- No text inside generated art unless the asset is explicitly a banner

## Folder Contract

```text
assets/images/
  backgrounds/
    cabin_default.png
    window_city_morning.png
  characters/
    passenger_worker.png
    passenger_vip.png
    mascot_station_cat.png
  slots/
    seat_lv1.png
    seat_lv2.png
    seat_lv3.png
    kiosk_lv1.png
    kiosk_lv2.png
    kiosk_lv3.png
  decorations/
    tiny_plant_lv1.png
    cat_doll_lv1.png
    cheer_poster_lv1.png
    route_map_lv1.png
    soft_rug_lv1.png
    lost_box_lv1.png
  ui/
    train_badge.png
    decor_manager.png
```

## Size Guide

| Asset Type | Size |
| --- | --- |
| Cabin background | 1600x900 |
| Window scenery | 800x360 |
| Slot objects | 512x512 |
| Characters and mascot | 512x512 |
| Decorations | 384x384 |
| UI banners | 1200x400 |

## Generation Prompts

Cabin background:

```text
Cute cozy 2D mobile game background, inside a commuter train cabin,
soft pixel-art inspired, clean bold outlines, warm cream wall, teal trims,
large train windows, simple readable mobile game shapes, no text, no people,
1600x900, polished casual idle game style
```

Seat object:

```text
Cute 2D mobile game train seat object, soft pixel-art inspired,
clean bold outline, teal cushion, warm highlights, transparent background,
single object centered, no text, readable at small size
```

Kiosk object:

```text
Cute mini train snack kiosk for a 2D mobile tycoon game,
soft pixel-art inspired, yellow body, coral awning, teal counter,
clean bold outline, transparent background, no text
```

Passenger:

```text
Cute commuter passenger character, 2D mobile game asset,
soft pixel-art inspired, simple rounded body, clean bold outline,
transparent background, warm friendly expression, no text
```

Mascot:

```text
Cute station cat mascot for a cozy train tycoon mobile game,
soft pixel-art inspired, clean bold outline, yellow scarf,
transparent background, round friendly shape, no text
```

Decoration:

```text
Cute train cabin decoration object for a mobile idle game,
soft pixel-art inspired, clean bold outline, transparent background,
single centered object, no text, readable at small size
```

## Replacement Steps

1. Add a PNG file to the matching folder.
2. Confirm the file name matches a key in `GameAssets`.
3. Set that asset entry's `available` value to `true`.
4. Run:

```powershell
& "C:\src\flutter\bin\dart.bat" analyze
& "C:\src\flutter\bin\flutter.bat" test
& "C:\src\flutter\bin\flutter.bat" build apk --debug
```

## Current Implementation Note

The game does not require final PNG files to run. `TrainCabin` already draws temporary 2D assets with code so the game can continue to evolve while final art is produced.
