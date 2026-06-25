import 'package:flutter/material.dart';

import '../data/balance_config.dart';
import '../../../core/assets/game_asset.dart';
import '../../../core/widgets/asset_sprite.dart';
import '../models/decoration.dart';
import '../models/game_state.dart';
import 'currency_pill.dart';

class DecorationPanel extends StatelessWidget {
  const DecorationPanel({
    required this.state,
    required this.onBuy,
    required this.onUpgrade,
    super.key,
  });

  final GameState state;
  final void Function(DecorationSlotKind slotKind, DecorationItem item) onBuy;
  final ValueChanged<DecorationSlotKind> onUpgrade;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F3E9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3CABD),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '장식 상점',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF243B3A),
                      ),
                    ),
                  ),
                  CurrencyPill(
                    icon: Icons.confirmation_number_rounded,
                    label: '${state.gold.floor()} G',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '빈 위치에는 장식을 사고, 배치된 장식은 바로 업그레이드합니다.',
                style: TextStyle(color: Color(0xFF65706C)),
              ),
              const SizedBox(height: 16),
              for (final slotKind in DecorationSlotKind.values) ...[
                _DecorationSlotSection(
                  slotKind: slotKind,
                  state: state,
                  onBuy: onBuy,
                  onUpgrade: onUpgrade,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DecorationSlotSection extends StatelessWidget {
  const _DecorationSlotSection({
    required this.slotKind,
    required this.state,
    required this.onBuy,
    required this.onUpgrade,
  });

  final DecorationSlotKind slotKind;
  final GameState state;
  final void Function(DecorationSlotKind slotKind, DecorationItem item) onBuy;
  final ValueChanged<DecorationSlotKind> onUpgrade;

  @override
  Widget build(BuildContext context) {
    final placed = state.decorations[slotKind];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(slotKind.icon, color: const Color(0xFF28413D)),
                const SizedBox(width: 8),
                Text(
                  slotKind.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF28413D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (placed == null)
              for (final item in DecorationCatalog.forSlot(slotKind))
                _DecorationShopRow(
                  item: item,
                  gold: state.gold,
                  onPressed: () => onBuy(slotKind, item),
                )
            else
              _PlacedDecorationRow(
                placed: placed,
                gold: state.gold,
                onUpgrade: () => onUpgrade(slotKind),
              ),
          ],
        ),
      ),
    );
  }
}

class _DecorationShopRow extends StatelessWidget {
  const _DecorationShopRow({
    required this.item,
    required this.gold,
    required this.onPressed,
  });

  final DecorationItem item;
  final double gold;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final affordable = gold >= item.baseCost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _DecorationIcon(item: item),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '+${item.incomePerLevel.toStringAsFixed(1)} G/s  매력 +${item.appealPerLevel}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              foregroundColor: affordable
                  ? const Color(0xFF0F705F)
                  : const Color(0xFF8B7E6E),
            ),
            child: Text('${item.baseCost} G'),
          ),
        ],
      ),
    );
  }
}

class _PlacedDecorationRow extends StatelessWidget {
  const _PlacedDecorationRow({
    required this.placed,
    required this.gold,
    required this.onUpgrade,
  });

  final PlacedDecoration placed;
  final double gold;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final item = DecorationCatalog.byId(placed.itemId);
    final isMaxed = placed.level >= BalanceConfig.maxDecorationLevel;
    final cost = item.costForLevel(placed.level);
    final affordable = gold >= cost && !isMaxed;

    return Row(
      children: [
        _DecorationIcon(item: item, level: placed.level),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.name} Lv.${placed.level}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                '+${(item.incomePerLevel * placed.level).toStringAsFixed(1)} G/s  매력 +${item.appealPerLevel * placed.level}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: isMaxed ? null : onUpgrade,
          style: FilledButton.styleFrom(
            backgroundColor: affordable ? null : const Color(0xFFE4DED2),
            foregroundColor: affordable ? null : const Color(0xFF8B7E6E),
          ),
          child: Text(isMaxed ? 'MAX' : '$cost G'),
        ),
      ],
    );
  }
}

class _DecorationIcon extends StatelessWidget {
  const _DecorationIcon({required this.item, this.level = 1});

  final DecorationItem item;
  final int level;

  @override
  Widget build(BuildContext context) {
    final assetKey = GameAssets.decorationLevelKey(item.assetId, level);

    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: AssetSprite(
        assetKey: assetKey,
        fallbackIcon: item.icon,
        fallbackColor: item.color,
        size: 46,
      ),
    );
  }
}
