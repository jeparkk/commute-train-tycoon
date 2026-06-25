import 'package:flutter/material.dart';

import '../models/game_state.dart';
import 'currency_pill.dart';

class GameHeader extends StatelessWidget {
  const GameHeader({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '출근열차 키우기',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF243B3A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '객실을 눌러 수익을 키우세요',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF65706C),
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
    );
  }
}
