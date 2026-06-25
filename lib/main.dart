import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CommuteTrainTycoonApp());
}

class CommuteTrainTycoonApp extends StatelessWidget {
  const CommuteTrainTycoonApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF2E7D73);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '출근열차 키우기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F0E6),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}

enum SlotKind {
  seat('좌석', Icons.event_seat_rounded, Color(0xFF4D8CC8)),
  kiosk('매점', Icons.local_cafe_rounded, Color(0xFFD1843C)),
  decor('장식', Icons.local_florist_rounded, Color(0xFF7A9D54));

  const SlotKind(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class UpgradeSlot {
  const UpgradeSlot({
    required this.kind,
    required this.level,
    required this.baseCost,
    required this.baseIncome,
  });

  final SlotKind kind;
  final int level;
  final int baseCost;
  final double baseIncome;

  int get nextCost => (baseCost * pow(1.72, level - 1)).round();
  double get incomePerSecond => baseIncome * level;
  bool get isMaxed => level >= 20;

  UpgradeSlot levelUp() {
    return UpgradeSlot(
      kind: kind,
      level: level + 1,
      baseCost: baseCost,
      baseIncome: baseIncome,
    );
  }
}

class GameState {
  const GameState({
    required this.gold,
    required this.slots,
    required this.lastSavedAt,
    required this.pendingOfflineGold,
    required this.focusBoostEnabled,
  });

  factory GameState.initial(DateTime now) {
    return GameState(
      gold: 180,
      slots: const {
        SlotKind.seat: UpgradeSlot(
          kind: SlotKind.seat,
          level: 1,
          baseCost: 80,
          baseIncome: 0.8,
        ),
        SlotKind.kiosk: UpgradeSlot(
          kind: SlotKind.kiosk,
          level: 1,
          baseCost: 120,
          baseIncome: 1.1,
        ),
        SlotKind.decor: UpgradeSlot(
          kind: SlotKind.decor,
          level: 1,
          baseCost: 160,
          baseIncome: 1.4,
        ),
      },
      lastSavedAt: now,
      pendingOfflineGold: 0,
      focusBoostEnabled: true,
    );
  }

  final double gold;
  final Map<SlotKind, UpgradeSlot> slots;
  final DateTime lastSavedAt;
  final int pendingOfflineGold;
  final bool focusBoostEnabled;

  double get baseIncomePerSecond {
    return slots.values.fold(0, (sum, slot) => sum + slot.incomePerSecond);
  }

  double get activeIncomePerSecond {
    return baseIncomePerSecond * (focusBoostEnabled ? 2 : 1);
  }

  int get trainAppeal {
    return slots.values.fold(0, (sum, slot) => sum + slot.level * 12);
  }

  GameState copyWith({
    double? gold,
    Map<SlotKind, UpgradeSlot>? slots,
    DateTime? lastSavedAt,
    int? pendingOfflineGold,
    bool? focusBoostEnabled,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      slots: slots ?? this.slots,
      lastSavedAt: lastSavedAt ?? this.lastSavedAt,
      pendingOfflineGold: pendingOfflineGold ?? this.pendingOfflineGold,
      focusBoostEnabled: focusBoostEnabled ?? this.focusBoostEnabled,
    );
  }
}

class GameStorage {
  static const _goldKey = 'gold';
  static const _lastSavedAtKey = 'lastSavedAt';
  static const _focusBoostKey = 'focusBoostEnabled';

  static String _levelKey(SlotKind kind) => '${kind.name}Level';

  Future<GameState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final base = GameState.initial(now);

    final lastSavedMillis = prefs.getInt(_lastSavedAtKey);
    final lastSavedAt = lastSavedMillis == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(lastSavedMillis);

    final slots = {
      for (final entry in base.slots.entries)
        entry.key: UpgradeSlot(
          kind: entry.value.kind,
          level: max(
            1,
            prefs.getInt(_levelKey(entry.key)) ?? entry.value.level,
          ),
          baseCost: entry.value.baseCost,
          baseIncome: entry.value.baseIncome,
        ),
    };

    final storedGold = prefs.getDouble(_goldKey) ?? base.gold;
    final focusBoostEnabled = prefs.getBool(_focusBoostKey) ?? true;
    final loaded = base.copyWith(
      gold: storedGold,
      slots: slots,
      lastSavedAt: lastSavedAt,
      focusBoostEnabled: focusBoostEnabled,
    );

    final offlineGold = OfflineRevenueCalculator.calculate(
      state: loaded,
      now: now,
    );

    return loaded.copyWith(lastSavedAt: now, pendingOfflineGold: offlineGold);
  }

  Future<void> save(GameState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_goldKey, state.gold);
    await prefs.setInt(
      _lastSavedAtKey,
      state.lastSavedAt.millisecondsSinceEpoch,
    );
    await prefs.setBool(_focusBoostKey, state.focusBoostEnabled);

    for (final entry in state.slots.entries) {
      await prefs.setInt(_levelKey(entry.key), entry.value.level);
    }
  }
}

class OfflineRevenueCalculator {
  static const maxOfflineDuration = Duration(hours: 6);
  static const offlineEfficiency = 0.35;

  static int calculate({required GameState state, required DateTime now}) {
    final elapsed = now.difference(state.lastSavedAt);
    if (elapsed.isNegative || elapsed.inSeconds < 10) {
      return 0;
    }

    final cappedSeconds = min(elapsed.inSeconds, maxOfflineDuration.inSeconds);

    return (state.baseIncomePerSecond * cappedSeconds * offlineEfficiency)
        .floor();
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _storage = GameStorage();
  GameState? _state;
  Timer? _incomeTimer;
  Timer? _saveTimer;
  String? _toast;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _incomeTimer?.cancel();
    _saveTimer?.cancel();
    _save();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _save();
    }
  }

  Future<void> _load() async {
    final loaded = await _storage.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _state = loaded;
    });

    _incomeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = _state;
      if (current == null) {
        return;
      }

      setState(() {
        _state = current.copyWith(
          gold: current.gold + current.activeIncomePerSecond,
        );
      });
    });

    _saveTimer = Timer.periodic(const Duration(seconds: 12), (_) => _save());
  }

  Future<void> _save() async {
    final current = _state;
    if (current == null) {
      return;
    }

    await _storage.save(
      current.copyWith(lastSavedAt: DateTime.now(), pendingOfflineGold: 0),
    );
  }

  void _claimOfflineGold({required bool doubled}) {
    final current = _state;
    if (current == null || current.pendingOfflineGold <= 0) {
      return;
    }

    final reward = current.pendingOfflineGold * (doubled ? 2 : 1);
    setState(() {
      _state = current.copyWith(
        gold: current.gold + reward,
        pendingOfflineGold: 0,
        lastSavedAt: DateTime.now(),
      );
      _toast = doubled ? '광고 정산 테스트: 보상 2배!' : '오프라인 보상 수금 완료';
    });
    _save();
  }

  void _upgrade(SlotKind kind) {
    final current = _state;
    if (current == null) {
      return;
    }

    final slot = current.slots[kind]!;
    if (slot.isMaxed) {
      setState(() => _toast = '${slot.kind.label}은 이미 최고 레벨입니다');
      return;
    }

    if (current.gold < slot.nextCost) {
      setState(() => _toast = '골드가 조금 부족합니다');
      return;
    }

    final nextSlots = Map<SlotKind, UpgradeSlot>.of(current.slots);
    nextSlots[kind] = slot.levelUp();

    setState(() {
      _state = current.copyWith(
        gold: current.gold - slot.nextCost,
        slots: nextSlots,
      );
      _toast = '${slot.kind.label} Lv.${slot.level + 1} 업그레이드!';
    });
    _save();
  }

  void _toggleFocusBoost(bool enabled) {
    final current = _state;
    if (current == null) {
      return;
    }

    setState(() {
      _state = current.copyWith(focusBoostEnabled: enabled);
      _toast = enabled ? '화면 ON 2배 수익 적용 중' : '기본 수익 모드';
    });
    _save();
  }

  void _claimWarpStubReward() {
    final current = _state;
    if (current == null) {
      return;
    }

    const reward = 75;
    setState(() {
      _state = current.copyWith(gold: current.gold + reward);
      _toast = '이동 보너스 스텁: +$reward G';
    });
    _save();
  }

  void _showComingSoon(String feature) {
    setState(() {
      _toast = '$feature은 2차 MVP에서 열립니다';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    return Scaffold(
      body: SafeArea(
        child: state == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  _GameContent(
                    state: state,
                    toast: _toast,
                    onUpgrade: _upgrade,
                    onToggleFocusBoost: _toggleFocusBoost,
                    onClaimOfflineGold: _claimOfflineGold,
                    onClaimWarpStubReward: _claimWarpStubReward,
                    onShowComingSoon: _showComingSoon,
                  ),
                ],
              ),
      ),
    );
  }
}

class _GameContent extends StatelessWidget {
  const _GameContent({
    required this.state,
    required this.toast,
    required this.onUpgrade,
    required this.onToggleFocusBoost,
    required this.onClaimOfflineGold,
    required this.onClaimWarpStubReward,
    required this.onShowComingSoon,
  });

  final GameState state;
  final String? toast;
  final ValueChanged<SlotKind> onUpgrade;
  final ValueChanged<bool> onToggleFocusBoost;
  final void Function({required bool doubled}) onClaimOfflineGold;
  final VoidCallback onClaimWarpStubReward;
  final ValueChanged<String> onShowComingSoon;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Header(state: state),
                  const SizedBox(height: 14),
                  _StatusPanel(
                    state: state,
                    onToggleFocusBoost: onToggleFocusBoost,
                  ),
                  const SizedBox(height: 14),
                  if (state.pendingOfflineGold > 0)
                    _OfflinePanel(
                      reward: state.pendingOfflineGold,
                      onClaimOfflineGold: onClaimOfflineGold,
                    ),
                  if (state.pendingOfflineGold > 0) const SizedBox(height: 14),
                  _TrainCabin(state: state, onUpgrade: onUpgrade),
                  const SizedBox(height: 14),
                  _BottomActions(
                    toast: toast,
                    onCabin: () {},
                    onMove: onClaimWarpStubReward,
                    onShop: () => onShowComingSoon('상점'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

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
        _CurrencyPill(
          icon: Icons.confirmation_number_rounded,
          label: '${state.gold.floor()} G',
        ),
      ],
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  const _CurrencyPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8D6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6C866), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF9B6A00)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF6A4A00),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({required this.state, required this.onToggleFocusBoost});

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

class _OfflinePanel extends StatelessWidget {
  const _OfflinePanel({required this.reward, required this.onClaimOfflineGold});

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

class _TrainCabin extends StatelessWidget {
  const _TrainCabin({required this.state, required this.onUpgrade});

  final GameState state;
  final ValueChanged<SlotKind> onUpgrade;

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
                    _UpgradeTile(
                      slot: state.slots[SlotKind.decor]!,
                      gold: state.gold,
                      wide: true,
                      onTap: () => onUpgrade(SlotKind.decor),
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
    this.wide = false,
  });

  final UpgradeSlot slot;
  final double gold;
  final VoidCallback onTap;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final affordable = gold >= slot.nextCost && !slot.isMaxed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: wide ? 156 : 164,
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

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.toast,
    required this.onCabin,
    required this.onMove,
    required this.onShop,
  });

  final String? toast;
  final VoidCallback onCabin;
  final VoidCallback onMove;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (toast != null)
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF263B39),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(
                toast!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (toast != null) const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _NavButton(
                icon: Icons.home_rounded,
                label: '객실',
                selected: true,
                onPressed: onCabin,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NavButton(
                icon: Icons.map_rounded,
                label: '이동',
                onPressed: onMove,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _NavButton(
                icon: Icons.storefront_rounded,
                label: '상점',
                onPressed: onShop,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: selected ? const Color(0xFFDFF2EF) : Colors.white,
        foregroundColor: const Color(0xFF26403C),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
