import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/movement_report.dart';

class MovementBonusSheet extends StatelessWidget {
  const MovementBonusSheet({
    required this.state,
    required this.locationBusy,
    required this.onSettleGpsMove,
    required this.onSettleDemoMove,
    super.key,
  });

  final GameState state;
  final bool locationBusy;
  final VoidCallback onSettleGpsMove;
  final VoidCallback onSettleDemoMove;

  @override
  Widget build(BuildContext context) {
    final report = state.lastMovementReport;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F3E9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                      color: const Color(0xFF4F6FA8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
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
                          '도착역 리포트',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF243B3A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '출발역과 도착역 사이 운행 거리를 정산합니다',
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
              const SizedBox(height: 16),
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
                      const _MovementMetaRow(
                        icon: Icons.route_rounded,
                        label: '정산 방식',
                        value: '실제 GPS',
                      ),
                      const SizedBox(height: 8),
                      _MovementMetaRow(
                        icon: Icons.speed_rounded,
                        label: '화면 ON 배속',
                        value: state.focusBoostEnabled ? '2배 적용' : '기본',
                      ),
                      const SizedBox(height: 8),
                      _MovementMetaRow(
                        icon: Icons.my_location_rounded,
                        label: '기준 위치',
                        value: state.movementCheckpoint.hasLocation
                            ? '저장됨'
                            : '필요',
                      ),
                      const SizedBox(height: 8),
                      _MovementMetaRow(
                        icon: Icons.confirmation_number_rounded,
                        label: '보유 워프 포인트',
                        value: '${state.warpPoints} WP',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (report.hasReward)
                _LastReportCard(report: report)
              else
                const _EmptyReportCard(),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: locationBusy ? null : onSettleGpsMove,
                icon: locationBusy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(locationBusy ? '도착역 확인 중' : '도착역 정산'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: onSettleDemoMove,
                icon: const Icon(Icons.directions_train_rounded),
                label: const Text('테스트 운행 정산'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LastReportCard extends StatelessWidget {
  const _LastReportCard({required this.report});

  final MovementReport report;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC5DED8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '최근 이동 정산',
              style: TextStyle(
                color: Color(0xFF243B3A),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            _MovementMetaRow(
              icon: Icons.alt_route_rounded,
              label: '이동 거리',
              value: '${report.distanceKm.toStringAsFixed(1)} km',
            ),
            const SizedBox(height: 6),
            _MovementMetaRow(
              icon: Icons.schedule_rounded,
              label: '이동 시간',
              value: _formatDuration(report.duration),
            ),
            const SizedBox(height: 6),
            _MovementMetaRow(
              icon: Icons.savings_rounded,
              label: '획득 보상',
              value: '+${report.gold} G / +${report.warpPoints} WP',
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    if (minutes > 0) {
      return '$minutes분 $seconds초';
    }
    return '$seconds초';
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          '아직 정산된 이동 기록이 없습니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF65706C),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MovementMetaRow extends StatelessWidget {
  const _MovementMetaRow({
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
