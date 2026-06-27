import 'package:flutter/material.dart';

import '../models/game_state.dart';
import 'currency_pill.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({
    required this.state,
    required this.onToggleFocusBoost,
    super.key,
  });

  final GameState state;
  final ValueChanged<bool> onToggleFocusBoost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5D8C3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D73),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_train_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '출근열차 키우기',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF243B3A),
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
          Row(
            children: [
              Expanded(
                child: _HudChip(
                  icon: Icons.savings_rounded,
                  label:
                      '수익 ${state.activeIncomePerSecond.toStringAsFixed(1)}/s',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _HudChip(
                  icon: Icons.favorite_rounded,
                  label: '매력 ${state.trainAppeal}',
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: _HudChip(
                  icon: Icons.confirmation_number_outlined,
                  label: 'WP ${state.warpPoints}',
                ),
              ),
              const SizedBox(width: 5),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF5F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFD3E9E4)),
                ),
                child: SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          '2x',
                          style: TextStyle(
                            color: Color(0xFF0F705F),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.66,
                        child: Switch(
                          value: state.focusBoostEnabled,
                          onChanged: onToggleFocusBoost,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0E6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5D8C3)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: const Color(0xFF2E7D73)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF263B39),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
