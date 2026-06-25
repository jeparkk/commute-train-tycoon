import 'package:flutter/material.dart';

import '../models/offline_reward.dart';

class OfflineRewardSheet extends StatelessWidget {
  const OfflineRewardSheet({
    required this.reward,
    required this.onClaim,
    super.key,
  });

  final OfflineReward reward;
  final void Function({required bool doubled}) onClaim;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F3E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D73),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '차고지 수익 도착',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF243B3A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '앱을 꺼둔 동안 열차가 운행했어요',
                          style: TextStyle(
                            color: Color(0xFF65706C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE1D8C8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '정산 가능 골드',
                        style: TextStyle(
                          color: Color(0xFF65706C),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reward.gold} G',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F705F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _OfflineMetaRow(
                        icon: Icons.schedule_rounded,
                        label: '누적 시간',
                        value: _formatDuration(reward.duration),
                      ),
                      const SizedBox(height: 6),
                      _OfflineMetaRow(
                        icon: Icons.battery_saver_rounded,
                        label: '방치 효율',
                        value: '${(reward.efficiency * 100).round()}%',
                      ),
                      if (reward.reachedCap) ...[
                        const SizedBox(height: 10),
                        const Text(
                          '금고가 가득 차서 추가 수익은 멈췄습니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF9B6A00),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => onClaim(doubled: false),
                      child: const Text('수금'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () => onClaim(doubled: true),
                      child: const Text('2배 정산 테스트'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '$hours시간 $minutes분';
    }
    return '$minutes분';
  }
}

class _OfflineMetaRow extends StatelessWidget {
  const _OfflineMetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF65706C)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF65706C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF243B3A),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
