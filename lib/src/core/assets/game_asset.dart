class GameAsset {
  const GameAsset({
    required this.key,
    required this.path,
    this.available = false,
  });

  final String key;
  final String path;
  final bool available;
}

class GameAssets {
  static const _assets = {
    'train_badge': GameAsset(
      key: 'train_badge',
      path: 'assets/images/ui/train_badge.png',
    ),
    'seat_lv1': GameAsset(
      key: 'seat_lv1',
      path: 'assets/images/slots/seat_lv1.png',
    ),
    'seat_lv2': GameAsset(
      key: 'seat_lv2',
      path: 'assets/images/slots/seat_lv2.png',
    ),
    'seat_lv3': GameAsset(
      key: 'seat_lv3',
      path: 'assets/images/slots/seat_lv3.png',
    ),
    'kiosk_lv1': GameAsset(
      key: 'kiosk_lv1',
      path: 'assets/images/slots/kiosk_lv1.png',
    ),
    'kiosk_lv2': GameAsset(
      key: 'kiosk_lv2',
      path: 'assets/images/slots/kiosk_lv2.png',
    ),
    'kiosk_lv3': GameAsset(
      key: 'kiosk_lv3',
      path: 'assets/images/slots/kiosk_lv3.png',
    ),
    'decor_manager': GameAsset(
      key: 'decor_manager',
      path: 'assets/images/ui/decor_manager.png',
    ),
    'tiny_plant_lv1': GameAsset(
      key: 'tiny_plant_lv1',
      path: 'assets/images/decorations/tiny_plant_lv1.png',
    ),
    'cat_doll_lv1': GameAsset(
      key: 'cat_doll_lv1',
      path: 'assets/images/decorations/cat_doll_lv1.png',
    ),
    'cheer_poster_lv1': GameAsset(
      key: 'cheer_poster_lv1',
      path: 'assets/images/decorations/cheer_poster_lv1.png',
    ),
    'route_map_lv1': GameAsset(
      key: 'route_map_lv1',
      path: 'assets/images/decorations/route_map_lv1.png',
    ),
    'soft_rug_lv1': GameAsset(
      key: 'soft_rug_lv1',
      path: 'assets/images/decorations/soft_rug_lv1.png',
    ),
    'lost_box_lv1': GameAsset(
      key: 'lost_box_lv1',
      path: 'assets/images/decorations/lost_box_lv1.png',
    ),
  };

  static GameAsset? byKey(String key) => _assets[key];

  static String slotLevelKey(String slotId, int level) {
    final cappedLevel = level.clamp(1, 3);
    return '${slotId}_lv$cappedLevel';
  }

  static String decorationLevelKey(String itemId, int level) {
    final cappedLevel = level.clamp(1, 3);
    return '${itemId}_lv$cappedLevel';
  }
}
