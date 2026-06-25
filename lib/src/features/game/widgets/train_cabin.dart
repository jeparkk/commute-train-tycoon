import 'package:flutter/material.dart';

import '../../../core/assets/game_asset.dart';
import '../../../core/widgets/asset_sprite.dart';
import '../models/game_state.dart';
import '../models/slot_kind.dart';
import '../models/upgrade_slot.dart';

class TrainCabin extends StatelessWidget {
  const TrainCabin({
    required this.state,
    required this.onUpgrade,
    required this.onOpenDecorations,
    super.key,
  });

  final GameState state;
  final ValueChanged<SlotKind> onUpgrade;
  final VoidCallback onOpenDecorations;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF4D8F9B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF27484F), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3327484F),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
        child: Column(
          children: [
            const _CabinRoof(),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF27484F), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  children: [
                    const _WindowRow(),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _UpgradeObject(
                            slot: state.slots[SlotKind.seat]!,
                            gold: state.gold,
                            onTap: () => onUpgrade(SlotKind.seat),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UpgradeObject(
                            slot: state.slots[SlotKind.kiosk]!,
                            gold: state.gold,
                            onTap: () => onUpgrade(SlotKind.kiosk),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DecorationObject(state: state, onTap: onOpenDecorations),
                    const SizedBox(height: 10),
                    const _CabinFloor(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinRoof extends StatelessWidget {
  const _CabinRoof();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFFFCF5A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF604822), width: 2),
          ),
          child: const Icon(Icons.train_rounded, color: Color(0xFF2B2C28)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFCDEEF5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF27484F), width: 2),
            ),
            child: const Center(
              child: Text(
                'COMMUTE EXPRESS',
                style: TextStyle(
                  color: Color(0xFF315A66),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WindowRow extends StatelessWidget {
  const _WindowRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 3 ? 0 : 7),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F6FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF598897), width: 2),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 26,
                  height: 18,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _UpgradeObject extends StatelessWidget {
  const _UpgradeObject({
    required this.slot,
    required this.gold,
    required this.onTap,
  });

  final UpgradeSlot slot;
  final double gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final affordable = gold >= slot.nextCost && !slot.isMaxed;

    return _CabinObjectButton(
      color: slot.kind.color,
      assetKey: GameAssets.slotLevelKey(slot.kind.assetId, slot.level),
      icon: slot.kind.icon,
      title: '${slot.kind.label} Lv.${slot.level}',
      subtitle: '+${slot.incomePerSecond.toStringAsFixed(1)} G/s',
      actionLabel: slot.isMaxed ? 'MAX' : '${slot.nextCost} G',
      isActionReady: affordable,
      onTap: onTap,
    );
  }
}

class _DecorationObject extends StatelessWidget {
  const _DecorationObject({required this.state, required this.onTap});

  final GameState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _CabinObjectButton(
      color: const Color(0xFF7A9D54),
      assetKey: 'decor_manager',
      icon: Icons.local_florist_rounded,
      title: '장식 관리',
      subtitle: '배치 ${state.placedDecorationCount}/3',
      actionLabel: '꾸미기',
      isActionReady: true,
      horizontal: true,
      onTap: onTap,
    );
  }
}

class _CabinObjectButton extends StatelessWidget {
  const _CabinObjectButton({
    required this.color,
    required this.assetKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.isActionReady,
    required this.onTap,
    this.horizontal = false,
  });

  final Color color;
  final String assetKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isActionReady;
  final VoidCallback onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: horizontal
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: horizontal ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF273735),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF4F5D58), fontSize: 12),
        ),
      ],
    );

    final content = [
      _ObjectSprite(color: color, icon: icon, assetKey: assetKey),
      SizedBox(width: horizontal ? 12 : 0, height: horizontal ? 0 : 8),
      if (horizontal) Expanded(child: details) else details,
      SizedBox(width: horizontal ? 10 : 0, height: horizontal ? 0 : 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActionReady
              ? const Color(0xFFE6FFF7)
              : const Color(0xFFF2EBDD),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActionReady
                ? const Color(0xFF0F705F)
                : const Color(0xFFC8BCAA),
          ),
        ),
        child: Text(
          actionLabel,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: isActionReady
                ? const Color(0xFF0F705F)
                : const Color(0xFF8B7E6E),
            fontSize: 12,
          ),
        ),
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: horizontal ? 118 : 190,
          decoration: BoxDecoration(
            color: Color.lerp(color, Colors.white, 0.82),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: horizontal
                ? Row(children: content)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: content,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ObjectSprite extends StatelessWidget {
  const _ObjectSprite({
    required this.color,
    required this.icon,
    required this.assetKey,
  });

  final Color color;
  final IconData icon;
  final String assetKey;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 64,
          height: 12,
          margin: const EdgeInsets.only(top: 54),
          decoration: BoxDecoration(
            color: const Color(0x33273B35),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: AssetSprite(
            assetKey: assetKey,
            fallbackIcon: icon,
            fallbackColor: color,
            size: 58,
          ),
        ),
      ],
    );
  }
}

class _CabinFloor extends StatelessWidget {
  const _CabinFloor();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFFE6D4AF),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Container(
              width: 22,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF7F7566),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
