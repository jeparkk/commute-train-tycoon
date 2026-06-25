# Game Image Assets

Add transparent PNG files here when replacing the current icon fallbacks.

## Folders

- `ui/`: shared UI sprites such as `train_badge.png` and `decor_manager.png`
- `slots/`: train upgrade objects such as `seat_lv1.png` and `kiosk_lv1.png`
- `decorations/`: decoration shop items such as `tiny_plant_lv1.png`

## Naming

Use the keys registered in `lib/src/core/assets/game_asset.dart`.

Examples:

```text
assets/images/slots/seat_lv1.png
assets/images/slots/seat_lv2.png
assets/images/decorations/tiny_plant_lv1.png
```

After adding a real PNG, set that asset's `available` value to `true` in `GameAssets`.
