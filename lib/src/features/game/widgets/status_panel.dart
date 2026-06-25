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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3E3428),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
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
            Switch(
              value: state.focusBoostEnabled,
              onChanged: onToggleFocusBoost,
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
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: const Color(0xFF6C7772)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF263B39),
          ),
        ),
      ],
    );
  }
}
