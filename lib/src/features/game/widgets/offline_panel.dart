import 'package:flutter/material.dart';

class OfflinePanel extends StatelessWidget {
  const OfflinePanel({
    required this.reward,
    required this.onClaimOfflineGold,
    super.key,
  });

  final int reward;
  final void Function({required bool doubled}) onClaimOfflineGold;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFECF8F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF91C9C0), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '차고지 대기 수익 도착',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1D4E48),
              ),
            ),
            const SizedBox(height: 8),
            Text('앱을 꺼둔 동안 $reward G가 쌓였습니다.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => onClaimOfflineGold(doubled: false),
                    child: const Text('수금'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => onClaimOfflineGold(doubled: true),
                    child: const Text('광고 2배 테스트'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
