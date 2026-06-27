# Game Image Assets

Add transparent PNG files here when replacing the current icon fallbacks.

## Folders

- `ui/`: shared UI sprites such as `train_badge.png` and `decor_manager.png`
- `backgrounds/`: cabin backgrounds and outside-window scenery
- `characters/`: passengers, VIP passengers, and the mascot
- `slots/`: train upgrade objects such as `seat_lv1.png` and `kiosk_lv1.png`
- `decorations/`: decoration shop items such as `tiny_plant_lv1.png`
- `concepts/`: art direction mockups and target screen references

## Naming

Use the keys registered in `lib/src/core/assets/game_asset.dart`.

Examples:

```text
assets/images/slots/seat_lv1.png
assets/images/slots/seat_lv2.png
assets/images/decorations/tiny_plant_lv1.png
assets/images/backgrounds/cabin_default.png
assets/images/characters/passenger_student.png
```

After adding a real PNG, set that asset's `available` value to `true` in `GameAssets`.

For the full production pipeline, see:

```text
docs/asset-pipeline.md
```

For the current Step 16 art/UI direction, see:

```text
docs/step16-art-ui-direction.md
```

## Art Direction

Use a soft pixel-inspired 2D illustration style:

- crisp outlines
- simple color blocks
- warm train cabin lighting
- teal, yellow, coral, mint, and cream accents
- transparent PNG for objects and characters
- high-resolution source files even when the style feels pixel-like

Suggested generation prompt:

```text
Cute cozy 2D mobile game asset, soft pixel-art inspired illustration,
clean bold outline, warm commuter train cabin, teal and yellow accents,
transparent background, simple readable shape, no text, no realism
```

Recommended sizes:

- cabin background: 1600x900
- slot objects: 512x512
- passengers and mascot: 512x512
- decorations: 384x384
- UI banners: 1200x400
