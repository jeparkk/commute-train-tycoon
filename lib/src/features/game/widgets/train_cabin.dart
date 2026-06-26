import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/decoration.dart';
import '../models/game_state.dart';
import '../models/slot_kind.dart';
import '../models/upgrade_slot.dart';

class TrainCabin extends StatefulWidget {
  const TrainCabin({
    required this.state,
    required this.incomePulse,
    required this.lostItemAvailable,
    required this.showFirstGoal,
    required this.onUpgrade,
    required this.onOpenDecorations,
    required this.onClaimLostItem,
    super.key,
  });

  final GameState state;
  final int incomePulse;
  final bool lostItemAvailable;
  final bool showFirstGoal;
  final ValueChanged<SlotKind> onUpgrade;
  final ValueChanged<DecorationSlotKind> onOpenDecorations;
  final VoidCallback onClaimLostItem;

  @override
  State<TrainCabin> createState() => _TrainCabinState();
}

class _TrainCabinState extends State<TrainCabin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final seat = widget.state.slots[SlotKind.seat]!;
    final kiosk = widget.state.slots[SlotKind.kiosk]!;
    final hasDecorations = widget.state.placedDecorationCount > 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = (math.sin(_controller.value * math.pi * 2) + 1) / 2;
        final bob = math.sin(_controller.value * math.pi * 2) * 2;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF316C74),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF263B39), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33263B39),
                blurRadius: 22,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1.18,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    const Positioned.fill(child: _CabinSceneBackground()),
                    const Positioned(
                      left: 18,
                      right: 18,
                      top: 24,
                      child: _WindowStrip(),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 8,
                      child: _TrackFloor(hasDecorations: hasDecorations),
                    ),
                    Positioned(
                      left: 28,
                      top: 126 + bob,
                      child: _Passenger(
                        color: const Color(0xFFEB7D65),
                        shirt: const Color(0xFFFFD36A),
                        label: '+팁',
                        delay: pulse,
                      ),
                    ),
                    Positioned(
                      right: 105,
                      top: 116 - bob,
                      child: _Passenger(
                        color: const Color(0xFF667BC6),
                        shirt: const Color(0xFF8ED5C2),
                        label: 'VIP',
                        delay: 1 - pulse,
                      ),
                    ),
                    _SceneTapTarget(
                      left: 18,
                      top: 174,
                      width: 175,
                      height: 122,
                      ready: _isReady(seat),
                      pulse: pulse,
                      label: '좌석 Lv.${seat.level}',
                      subLabel: seat.isMaxed ? 'MAX' : '${seat.nextCost} G',
                      onTap: () => widget.onUpgrade(SlotKind.seat),
                      child: _SeatObject(level: seat.level),
                    ),
                    _SceneTapTarget(
                      right: 16,
                      top: 154,
                      width: 128,
                      height: 150,
                      ready: _isReady(kiosk),
                      pulse: 1 - pulse,
                      label: '매점 Lv.${kiosk.level}',
                      subLabel: kiosk.isMaxed ? 'MAX' : '${kiosk.nextCost} G',
                      onTap: () => widget.onUpgrade(SlotKind.kiosk),
                      child: _KioskObject(level: kiosk.level),
                    ),
                    _DecorationSlot(
                      left: 22,
                      top: 94,
                      title: '창가 장식',
                      placed:
                          widget.state.decorations[DecorationSlotKind.window],
                      pulse: pulse,
                      onTap: () =>
                          widget.onOpenDecorations(DecorationSlotKind.window),
                    ),
                    _DecorationSlot(
                      right: 145,
                      top: 93,
                      title: '벽 장식',
                      placed: widget.state.decorations[DecorationSlotKind.wall],
                      pulse: 1 - pulse,
                      onTap: () =>
                          widget.onOpenDecorations(DecorationSlotKind.wall),
                    ),
                    _DecorationSlot(
                      left: 210,
                      bottom: 39,
                      title: '바닥 장식',
                      placed:
                          widget.state.decorations[DecorationSlotKind.floor],
                      pulse: pulse,
                      onTap: () =>
                          widget.onOpenDecorations(DecorationSlotKind.floor),
                    ),
                    Positioned(
                      right: 20,
                      bottom: 28 + bob,
                      child: _Mascot(energized: widget.state.focusBoostEnabled),
                    ),
                    if (widget.lostItemAvailable)
                      Positioned(
                        left: 185,
                        bottom: 72,
                        child: _LostItem(
                          pulse: pulse,
                          onTap: widget.onClaimLostItem,
                        ),
                      ),
                    if (widget.incomePulse > 0)
                      Positioned(
                        left: 130,
                        bottom: 145,
                        child: _FloatingIncome(
                          pulseKey: widget.incomePulse,
                          amount: widget.state.activeIncomePerSecond,
                        ),
                      ),
                    if (widget.showFirstGoal)
                      const Positioned(
                        left: 92,
                        top: 52,
                        child: _FirstGoalTicket(),
                      ),
                    Positioned(
                      left: 12,
                      top: 10,
                      child: _SceneBadge(
                        text: 'COMMUTE EXPRESS',
                        icon: Icons.train_rounded,
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 10,
                      child: _IncomeBubble(
                        text:
                            '+${widget.state.activeIncomePerSecond.toStringAsFixed(1)} G/s',
                        pulse: pulse,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isReady(UpgradeSlot slot) {
    return widget.state.gold >= slot.nextCost && !slot.isMaxed;
  }
}

class _CabinSceneBackground extends StatelessWidget {
  const _CabinSceneBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _CabinBackgroundPainter());
  }
}

class _CabinBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final wall = Paint()..color = const Color(0xFFFFF1CF);
    final lowerWall = Paint()..color = const Color(0xFFF4CF87);
    final floor = Paint()..color = const Color(0xFFD7B979);
    final line = Paint()
      ..color = const Color(0xFF27484F)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final trim = Paint()..color = const Color(0xFF46A49D);

    canvas.drawRect(Offset.zero & size, wall);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      floor,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.54, size.width, size.height * 0.1),
      lowerWall,
    );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, 18), trim);
    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.62),
      line,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.54),
      Offset(size.width, size.height * 0.54),
      Paint()
        ..color = const Color(0xFFC39D58)
        ..strokeWidth = 2,
    );

    for (var i = 0; i < 8; i++) {
      final y = size.height * 0.7 + i * 18;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 22),
        Paint()
          ..color = const Color(0x1A604822)
          ..strokeWidth = 2,
      );
    }

    canvas.drawRect(Offset.zero & size, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WindowStrip extends StatelessWidget {
  const _WindowStrip();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
            child: const _CabinWindow(),
          ),
        );
      }),
    );
  }
}

class _CabinWindow extends StatelessWidget {
  const _CabinWindow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFFAEE6F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF315A66), width: 3),
      ),
      child: CustomPaint(painter: _WindowPainter()),
    );
  }
}

class _WindowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()..color = const Color(0xFFAEE6F3);
    final hill = Paint()..color = const Color(0xFF87C97A);
    final building = Paint()..color = const Color(0xFFEFF7F4);
    final shine = Paint()..color = const Color(0x99FFFFFF);

    canvas.drawRect(Offset.zero & size, sky);
    canvas.drawOval(
      Rect.fromLTWH(-10, size.height * 0.5, size.width * 0.75, 36),
      hill,
    );
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.42, size.height * 0.48, size.width, 38),
      Paint()..color = const Color(0xFF69B778),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(12 + i * 28, 28 - i * 4, 18, 28 + i * 2),
          const Radius.circular(2),
        ),
        building,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 6, size.width * 0.4, 14),
        const Radius.circular(6),
      ),
      shine,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SceneTapTarget extends StatelessWidget {
  const _SceneTapTarget({
    required this.top,
    required this.width,
    required this.height,
    required this.ready,
    required this.pulse,
    required this.label,
    required this.subLabel,
    required this.onTap,
    required this.child,
    this.left,
    this.right,
  });

  final double? left;
  final double? right;
  final double top;
  final double width;
  final double height;
  final bool ready;
  final double pulse;
  final String label;
  final String subLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: child),
              if (ready)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Color.lerp(
                            const Color(0x00FFFFFF),
                            const Color(0xFFFFF5A8),
                            pulse,
                          )!,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.lerp(
                              const Color(0x00FFF5A8),
                              const Color(0x66FFF5A8),
                              pulse,
                            )!,
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 8,
                right: 8,
                bottom: -8,
                child: _ObjectLabel(
                  label: label,
                  subLabel: subLabel,
                  ready: ready,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObjectLabel extends StatelessWidget {
  const _ObjectLabel({
    required this.label,
    required this.subLabel,
    required this.ready,
  });

  final String label;
  final String subLabel;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ready ? const Color(0xFFF9E57A) : const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ready ? const Color(0xFF9B6A00) : const Color(0xFFE1D8C8),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263B39),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              subLabel,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF70550B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeatObject extends StatelessWidget {
  const _SeatObject({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final capped = level.clamp(1, 3);
    final color = [
      const Color(0xFF4E9B8C),
      const Color(0xFF5F8DC7),
      const Color(0xFFC27B65),
    ][capped - 1];

    return CustomPaint(
      painter: _SeatPainter(color: color, level: capped),
      child: const SizedBox.expand(),
    );
  }
}

class _SeatPainter extends CustomPainter {
  _SeatPainter({required this.color, required this.level});

  final Color color;
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()..color = const Color(0xFF263B39);
    final base = Paint()..color = color;
    final cushion = Paint()..color = Color.lerp(color, Colors.white, 0.28)!;
    final shadow = Paint()..color = const Color(0x33263B39);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.78,
        size.width * 0.8,
        18,
      ),
      shadow,
    );

    for (var i = 0; i < 2; i++) {
      final x = size.width * (0.08 + i * 0.42);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, size.height * 0.2, size.width * 0.36, 56),
          const Radius.circular(10),
        ),
        outline,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + 4,
            size.height * 0.2 + 4,
            size.width * 0.36 - 8,
            48,
          ),
          const Radius.circular(8),
        ),
        cushion,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 2, size.height * 0.58, size.width * 0.4, 28),
          const Radius.circular(9),
        ),
        outline,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x + 3,
            size.height * 0.58 + 4,
            size.width * 0.4 - 10,
            20,
          ),
          const Radius.circular(7),
        ),
        base,
      );
    }

    if (level >= 2) {
      final rail = Paint()
        ..color = const Color(0xFFFFD36A)
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(size.width * 0.04, size.height * 0.18),
        Offset(size.width * 0.9, size.height * 0.18),
        rail,
      );
    }
    if (level >= 3) {
      final sparkle = Paint()..color = const Color(0xFFFFF5A8);
      canvas.drawCircle(
        Offset(size.width * 0.84, size.height * 0.32),
        5,
        sparkle,
      );
      canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.42),
        3,
        sparkle,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SeatPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.level != level;
  }
}

class _KioskObject extends StatelessWidget {
  const _KioskObject({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _KioskPainter(level: level.clamp(1, 3)),
      child: const SizedBox.expand(),
    );
  }
}

class _KioskPainter extends CustomPainter {
  _KioskPainter({required this.level});

  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()..color = const Color(0xFF263B39);
    final body = Paint()..color = const Color(0xFFFFC857);
    final counter = Paint()..color = const Color(0xFF4E9B8C);
    final awning = Paint()..color = const Color(0xFFEB7D65);
    final glass = Paint()..color = const Color(0xFFCDEEF5);

    canvas.drawOval(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.84,
        size.width * 0.82,
        18,
      ),
      Paint()..color = const Color(0x33263B39),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.12,
          size.height * 0.24,
          size.width * 0.72,
          84,
        ),
        const Radius.circular(10),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.16,
          size.height * 0.28,
          size.width * 0.64,
          76,
        ),
        const Radius.circular(8),
      ),
      body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.1,
          size.height * 0.16,
          size.width * 0.76,
          24,
        ),
        const Radius.circular(8),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.14,
          size.height * 0.18,
          size.width * 0.68,
          18,
        ),
        const Radius.circular(6),
      ),
      awning,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.25,
          size.height * 0.36,
          size.width * 0.38,
          26,
        ),
        const Radius.circular(5),
      ),
      glass,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.08,
          size.height * 0.68,
          size.width * 0.8,
          24,
        ),
        const Radius.circular(8),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.13,
          size.height * 0.7,
          size.width * 0.7,
          18,
        ),
        const Radius.circular(6),
      ),
      counter,
    );

    if (level >= 2) {
      final sign = Paint()..color = const Color(0xFFFFF6DF);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.28,
            size.height * 0.07,
            size.width * 0.42,
            20,
          ),
          const Radius.circular(6),
        ),
        outline,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * 0.31,
            size.height * 0.085,
            size.width * 0.36,
            14,
          ),
          const Radius.circular(4),
        ),
        sign,
      );
    }
    if (level >= 3) {
      final lamp = Paint()..color = const Color(0xFFFFF5A8);
      canvas.drawCircle(Offset(size.width * 0.72, size.height * 0.46), 6, lamp);
      canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.46), 4, lamp);
    }
  }

  @override
  bool shouldRepaint(covariant _KioskPainter oldDelegate) {
    return oldDelegate.level != level;
  }
}

class _DecorationSlot extends StatelessWidget {
  const _DecorationSlot({
    required this.title,
    required this.placed,
    required this.pulse,
    required this.onTap,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final String title;
  final PlacedDecoration? placed;
  final double pulse;
  final VoidCallback onTap;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    final item = placed == null ? null : DecorationCatalog.byId(placed!.itemId);
    final label = item == null ? '+' : 'Lv.${placed!.level}';

    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      width: 80,
      height: 58,
      child: Tooltip(
        message: title,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: item == null
                    ? Colors.white.withValues(alpha: 0.38)
                    : Color.lerp(item.color, Colors.white, 0.66),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: item == null
                      ? Color.lerp(
                          const Color(0x889B6A00),
                          const Color(0xFFFFD36A),
                          pulse,
                        )!
                      : item.color,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 4,
                    left: 3,
                    right: 3,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF4F5D58),
                      ),
                    ),
                  ),
                  Icon(
                    item?.icon ?? Icons.add_rounded,
                    color: item?.color ?? const Color(0xFF9B6A00),
                    size: 26,
                  ),
                  Positioned(
                    right: 5,
                    bottom: 4,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF263B39),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Passenger extends StatelessWidget {
  const _Passenger({
    required this.color,
    required this.shirt,
    required this.label,
    required this.delay,
  });

  final Color color;
  final Color shirt;
  final String label;
  final double delay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 82,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 0,
            child: Opacity(
              opacity: 0.6 + delay * 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE1D8C8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F705F),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: CustomPaint(
              painter: _PassengerPainter(color: color, shirt: shirt),
              size: const Size(38, 60),
            ),
          ),
        ],
      ),
    );
  }
}

class _PassengerPainter extends CustomPainter {
  _PassengerPainter({required this.color, required this.shirt});

  final Color color;
  final Color shirt;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()..color = const Color(0xFF263B39);
    canvas.drawCircle(Offset(size.width / 2, 12), 11, outline);
    canvas.drawCircle(Offset(size.width / 2, 12), 8, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(7, 22, size.width - 14, 26),
        const Radius.circular(9),
      ),
      outline,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 25, size.width - 20, 20),
        const Radius.circular(7),
      ),
      Paint()..color = shirt,
    );
    canvas.drawLine(
      Offset(13, 48),
      Offset(10, 58),
      Paint()
        ..color = outline.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      Offset(size.width - 13, 48),
      Offset(size.width - 10, 58),
      Paint()
        ..color = outline.color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PassengerPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shirt != shirt;
  }
}

class _Mascot extends StatelessWidget {
  const _Mascot({required this.energized});

  final bool energized;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 58,
      child: Stack(
        children: [
          CustomPaint(
            painter: _MascotPainter(energized: energized),
            size: const Size(54, 58),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: energized ? const Color(0xFFFFF5A8) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE1D8C8)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  energized ? '2x' : '휴식',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF70550B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter({required this.energized});

  final bool energized;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()..color = const Color(0xFF263B39);
    final fur = Paint()
      ..color = energized ? const Color(0xFFFFD36A) : const Color(0xFFD6C6B0);
    final face = Paint()..color = const Color(0xFFFFF1CF);

    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 20, 38, 30),
      const Radius.circular(16),
    );
    canvas.drawRRect(body, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(11, 23, 32, 24),
        const Radius.circular(14),
      ),
      fur,
    );
    final head = Rect.fromLTWH(13, 8, 28, 28);
    canvas.drawOval(head, outline);
    canvas.drawOval(Rect.fromLTWH(16, 11, 22, 22), face);
    final earPath = Path()
      ..moveTo(15, 14)
      ..lineTo(18, 4)
      ..lineTo(24, 13)
      ..close()
      ..moveTo(38, 14)
      ..lineTo(35, 4)
      ..lineTo(29, 13)
      ..close();
    canvas.drawPath(earPath, outline);
    canvas.drawCircle(const Offset(22, 22), 2, outline);
    canvas.drawCircle(const Offset(32, 22), 2, outline);
    canvas.drawCircle(
      const Offset(27, 26),
      2,
      Paint()..color = const Color(0xFFEB7D65),
    );
  }

  @override
  bool shouldRepaint(covariant _MascotPainter oldDelegate) {
    return oldDelegate.energized != energized;
  }
}

class _LostItem extends StatelessWidget {
  const _LostItem({required this.pulse, required this.onTap});

  final double pulse;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '분실물',
      child: Transform.scale(
        scale: 0.94 + pulse * 0.08,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF9B6A00), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Color.lerp(
                      const Color(0x11FFF5A8),
                      const Color(0xAAFFF5A8),
                      pulse,
                    )!,
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: 20,
                      color: Color(0xFFD2A84F),
                    ),
                    Text(
                      '분실물',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF70550B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingIncome extends StatelessWidget {
  const _FloatingIncome({required this.pulseKey, required this.amount});

  final int pulseKey;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(pulseKey),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 820),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(0, -34 * value),
            child: Transform.scale(scale: 0.85 + value * 0.2, child: child),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5A8),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF9B6A00), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Text(
            '+${amount.toStringAsFixed(1)} G',
            style: const TextStyle(
              color: Color(0xFF70550B),
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstGoalTicket extends StatelessWidget {
  const _FirstGoalTicket();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6DF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD2A84F), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, size: 15, color: Color(0xFF9B6A00)),
            SizedBox(width: 5),
            Text(
              '첫 목표: 좌석 승급',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Color(0xFF70550B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackFloor extends StatelessWidget {
  const _TrackFloor({required this.hasDecorations});

  final bool hasDecorations;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 26,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: hasDecorations
                    ? const Color(0xFF7A9D54)
                    : const Color(0xFF7F7566),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SceneBadge extends StatelessWidget {
  const _SceneBadge({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xEEFFFFFF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF2E7D73)),
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF315A66),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeBubble extends StatelessWidget {
  const _IncomeBubble({required this.text, required this.pulse});

  final String text;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -pulse * 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF0F705F),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
