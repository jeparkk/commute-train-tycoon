import 'package:flutter/material.dart';

import '../assets/game_asset.dart';

class AssetSprite extends StatelessWidget {
  const AssetSprite({
    required this.assetKey,
    required this.fallbackIcon,
    required this.fallbackColor,
    this.size = 58,
    super.key,
  });

  final String assetKey;
  final IconData fallbackIcon;
  final Color fallbackColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = GameAssets.byKey(assetKey);

    if (asset != null && asset.available) {
      return Image.asset(
        asset.path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _FallbackSprite(
          icon: fallbackIcon,
          color: fallbackColor,
          size: size,
        ),
      );
    }

    return _FallbackSprite(
      icon: fallbackIcon,
      color: fallbackColor,
      size: size,
    );
  }
}

class _FallbackSprite extends StatelessWidget {
  const _FallbackSprite({
    required this.icon,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.55),
    );
  }
}
