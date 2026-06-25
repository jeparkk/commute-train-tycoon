import 'package:flutter/material.dart';

import '../models/game_state.dart';
import 'currency_pill.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5D8C3)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D73),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.directions_train_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '출근열차 키우기',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF243B3A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '객실을 눌러 수익을 키우세요',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF65706C),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          CurrencyPill(
            icon: Icons.confirmation_number_rounded,
            label: '${state.gold.floor()} G',
          ),
        ],
      ),
    );
  }
}
