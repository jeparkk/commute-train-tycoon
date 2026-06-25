import 'package:flutter/material.dart';

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
        color: const Color(0xFF7CB8C9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF315A66), width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD56D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF684F1E),
                      width: 2,
                    ),
                  ),
                  child: const Icon(Icons.train_rounded, size: 22),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF6FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF315A66),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFDF7E8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF315A66), width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _UpgradeTile(
                            slot: state.slots[SlotKind.seat]!,
                            gold: state.gold,
                            onTap: () => onUpgrade(SlotKind.seat),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _UpgradeTile(
                            slot: state.slots[SlotKind.kiosk]!,
                            gold: state.gold,
                            onTap: () => onUpgrade(SlotKind.kiosk),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _DecorationManagerTile(
                      state: state,
                      onTap: onOpenDecorations,
                    ),
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

class _UpgradeTile extends StatelessWidget {
  const _UpgradeTile({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 164,
          decoration: BoxDecoration(
            color: slot.kind.color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: affordable ? slot.kind.color : const Color(0xFFC8BCAA),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: slot.kind.color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(slot.kind.icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 8),
                Text(
                  '${slot.kind.label} Lv.${slot.level}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF273735),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${slot.incomePerSecond.toStringAsFixed(1)} G/s',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Text(
                  slot.isMaxed ? 'MAX' : '${slot.nextCost} G',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: affordable
                        ? const Color(0xFF0F705F)
                        : const Color(0xFF8B7E6E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorationManagerTile extends StatelessWidget {
  const _DecorationManagerTile({required this.state, required this.onTap});

  final GameState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 156,
          decoration: BoxDecoration(
            color: const Color(0xFF7A9D54).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF7A9D54), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A9D54),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_florist_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '장식 관리',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273735),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('배치 ${state.placedDecorationCount}/3'),
                      const SizedBox(height: 8),
                      const Text(
                        '구매, 자동 배치, 업그레이드',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF56704E),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
