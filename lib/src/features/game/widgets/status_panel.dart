import 'package:flutter/material.dart';

import '../models/game_state.dart';

class StatusPanel extends StatelessWidget {
  const StatusPanel({
    required this.state,
    required this.onToggleFocusBoost,
    super.key,
  });

  final GameState state;
  final ValueChanged<bool> onToggleFocusBoost;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 8, 7),
        child: Row(
          children: [
            Expanded(
              child: _Metric(
                label: '초당 수익',
                value: '+${state.activeIncomePerSecond.toStringAsFixed(1)} G',
              ),
            ),
            Expanded(
              child: _Metric(label: '열차 매력', value: '${state.trainAppeal}'),
            ),
            Transform.scale(
              scale: 0.82,
              alignment: Alignment.centerRight,
              child: Switch(
                value: state.focusBoostEnabled,
                onChanged: onToggleFocusBoost,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF6C7772),
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF263B39),
          ),
        ),
      ],
    );
  }
}
