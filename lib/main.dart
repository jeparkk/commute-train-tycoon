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
  kiosk('매점', Icons.local_cafe_rounded, Color(0xFFD1843C));

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

enum DecorationSlotKind {
  window('창가', Icons.window_rounded),
  wall('벽면', Icons.image_rounded),
  floor('바닥', Icons.layers_rounded);

  const DecorationSlotKind(this.label, this.icon);

  final String label;
  final IconData icon;
}

class DecorationItem {
  const DecorationItem({
    required this.id,
    required this.slotKind,
    required this.name,
    required this.icon,
    required this.color,
    required this.baseCost,
    required this.incomePerLevel,
    required this.appealPerLevel,
  });

  final String id;
  final DecorationSlotKind slotKind;
  final String name;
  final IconData icon;
  final Color color;
  final int baseCost;
  final double incomePerLevel;
  final int appealPerLevel;

  int costForLevel(int currentLevel) {
    return (baseCost * pow(1.62, currentLevel)).round();
  }
}

class PlacedDecoration {
  const PlacedDecoration({required this.itemId, required this.level});

  final String itemId;
  final int level;

  PlacedDecoration levelUp() {
    return PlacedDecoration(itemId: itemId, level: level + 1);
  }
}

class DecorationCatalog {
  static const items = [
    DecorationItem(
      id: 'tiny_plant',
      slotKind: DecorationSlotKind.window,
      name: '작은 화분',
      icon: Icons.local_florist_rounded,
      color: Color(0xFF7A9D54),
      baseCost: 140,
      incomePerLevel: 0.3,
      appealPerLevel: 16,
    ),
    DecorationItem(
      id: 'cat_doll',
      slotKind: DecorationSlotKind.window,
      name: '고양이 인형',
      icon: Icons.pets_rounded,
      color: Color(0xFFC27B65),
      baseCost: 360,
      incomePerLevel: 0.7,
      appealPerLevel: 34,
    ),
    DecorationItem(
      id: 'cheer_poster',
      slotKind: DecorationSlotKind.wall,
      name: '출근 응원 포스터',
      icon: Icons.campaign_rounded,
      color: Color(0xFF5F8DC7),
      baseCost: 180,
      incomePerLevel: 0.4,
      appealPerLevel: 20,
    ),
    DecorationItem(
      id: 'route_map',
      slotKind: DecorationSlotKind.wall,
      name: '미니 노선도',
      icon: Icons.map_rounded,
      color: Color(0xFF7367A8),
      baseCost: 420,
      incomePerLevel: 0.8,
      appealPerLevel: 38,
    ),
    DecorationItem(
      id: 'soft_rug',
      slotKind: DecorationSlotKind.floor,
      name: '폭신 러그',
      icon: Icons.grid_view_rounded,
      color: Color(0xFFD2A84F),
      baseCost: 220,
      incomePerLevel: 0.5,
      appealPerLevel: 24,
    ),
    DecorationItem(
      id: 'lost_box',
      slotKind: DecorationSlotKind.floor,
      name: '분실물 박스',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF4E9B8C),
      baseCost: 520,
      incomePerLevel: 1.0,
      appealPerLevel: 44,
    ),
  ];

  static DecorationItem byId(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  static List<DecorationItem> forSlot(DecorationSlotKind slotKind) {
    return items.where((item) => item.slotKind == slotKind).toList();
  }
}

class GameState {
  const GameState({
    required this.gold,
    required this.slots,
    required this.decorations,
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
      },
      decorations: const {
        DecorationSlotKind.window: null,
        DecorationSlotKind.wall: null,
        DecorationSlotKind.floor: null,
      },
      lastSavedAt: now,
      pendingOfflineGold: 0,
      focusBoostEnabled: true,
    );
  }

  final double gold;
  final Map<SlotKind, UpgradeSlot> slots;
  final Map<DecorationSlotKind, PlacedDecoration?> decorations;
  final DateTime lastSavedAt;
  final int pendingOfflineGold;
  final bool focusBoostEnabled;

  double get baseIncomePerSecond {
    final slotIncome = slots.values.fold<double>(
      0,
      (sum, slot) => sum + slot.incomePerSecond,
    );
    final decorationIncome = decorations.values
        .whereType<PlacedDecoration>()
        .fold<double>(0, (sum, placed) {
          final item = DecorationCatalog.byId(placed.itemId);
          return sum + item.incomePerLevel * placed.level;
        });

    return slotIncome + decorationIncome;
  }

  double get activeIncomePerSecond {
    return baseIncomePerSecond * (focusBoostEnabled ? 2 : 1);
  }

  int get trainAppeal {
    final slotAppeal = slots.values.fold<int>(
      0,
      (sum, slot) => sum + slot.level * 12,
    );
    final decorationAppeal = decorations.values
        .whereType<PlacedDecoration>()
        .fold<int>(0, (sum, placed) {
          final item = DecorationCatalog.byId(placed.itemId);
          return sum + item.appealPerLevel * placed.level;
        });

    return slotAppeal + decorationAppeal;
  }

  int get placedDecorationCount {
    return decorations.values.whereType<PlacedDecoration>().length;
  }

  GameState copyWith({
    double? gold,
    Map<SlotKind, UpgradeSlot>? slots,
    Map<DecorationSlotKind, PlacedDecoration?>? decorations,
    DateTime? lastSavedAt,
    int? pendingOfflineGold,
    bool? focusBoostEnabled,
  }) {
    return GameState(
      gold: gold ?? this.gold,
      slots: slots ?? this.slots,
      decorations: decorations ?? this.decorations,
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
  static String _decorationItemKey(DecorationSlotKind kind) =>
      '${kind.name}DecorationItem';
  static String _decorationLevelKey(DecorationSlotKind kind) =>
      '${kind.name}DecorationLevel';

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
    final decorations = {
      for (final slotKind in DecorationSlotKind.values)
        slotKind: _loadDecoration(prefs, slotKind),
    };

    final storedGold = prefs.getDouble(_goldKey) ?? base.gold;
    final focusBoostEnabled = prefs.getBool(_focusBoostKey) ?? true;
    final loaded = base.copyWith(
      gold: storedGold,
      slots: slots,
      decorations: decorations,
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

    for (final entry in state.decorations.entries) {
      final placed = entry.value;
      if (placed == null) {
        await prefs.remove(_decorationItemKey(entry.key));
        await prefs.remove(_decorationLevelKey(entry.key));
      } else {
        await prefs.setString(_decorationItemKey(entry.key), placed.itemId);
        await prefs.setInt(_decorationLevelKey(entry.key), placed.level);
      }
    }
  }

  PlacedDecoration? _loadDecoration(
    SharedPreferences prefs,
    DecorationSlotKind slotKind,
  ) {
    final itemId = prefs.getString(_decorationItemKey(slotKind));
    if (itemId == null || !DecorationCatalog.items.any((i) => i.id == itemId)) {
      return null;
    }

    final item = DecorationCatalog.byId(itemId);
    if (item.slotKind != slotKind) {
      return null;
    }

    return PlacedDecoration(
      itemId: itemId,
      level: max(1, prefs.getInt(_decorationLevelKey(slotKind)) ?? 1),
    );
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

  void _openDecorationPanel() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final current = _state;
            if (current == null) {
              return const SizedBox.shrink();
            }

            return _DecorationPanel(
              state: current,
              onBuy: (slotKind, item) {
                _buyDecoration(slotKind, item);
                setModalState(() {});
              },
              onUpgrade: (slotKind) {
                _upgradeDecoration(slotKind);
                setModalState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _buyDecoration(DecorationSlotKind slotKind, DecorationItem item) {
    final current = _state;
    if (current == null) {
      return;
    }

    if (current.decorations[slotKind] != null) {
      setState(() => _toast = '${slotKind.label}에는 이미 장식이 있습니다');
      return;
    }

    if (current.gold < item.baseCost) {
      setState(() => _toast = '장식을 사기엔 골드가 부족합니다');
      return;
    }

    final nextDecorations = Map<DecorationSlotKind, PlacedDecoration?>.of(
      current.decorations,
    );
    nextDecorations[slotKind] = PlacedDecoration(itemId: item.id, level: 1);

    setState(() {
      _state = current.copyWith(
        gold: current.gold - item.baseCost,
        decorations: nextDecorations,
      );
      _toast = '${item.name} 배치 완료!';
    });
    _save();
  }

  void _upgradeDecoration(DecorationSlotKind slotKind) {
    final current = _state;
    final placed = current?.decorations[slotKind];
    if (current == null || placed == null) {
      return;
    }

    final item = DecorationCatalog.byId(placed.itemId);
    if (placed.level >= 10) {
      setState(() => _toast = '${item.name}은 이미 최고 레벨입니다');
      return;
    }

    final cost = item.costForLevel(placed.level);
    if (current.gold < cost) {
      setState(() => _toast = '장식 업그레이드 골드가 부족합니다');
      return;
    }

    final nextDecorations = Map<DecorationSlotKind, PlacedDecoration?>.of(
      current.decorations,
    );
    nextDecorations[slotKind] = placed.levelUp();

    setState(() {
      _state = current.copyWith(
        gold: current.gold - cost,
        decorations: nextDecorations,
      );
      _toast = '${item.name} Lv.${placed.level + 1} 업그레이드!';
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
                    onOpenDecorations: _openDecorationPanel,
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
    required this.onOpenDecorations,
    required this.onToggleFocusBoost,
    required this.onClaimOfflineGold,
    required this.onClaimWarpStubReward,
    required this.onShowComingSoon,
  });

  final GameState state;
  final String? toast;
  final ValueChanged<SlotKind> onUpgrade;
  final VoidCallback onOpenDecorations;
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
                  _TrainCabin(
                    state: state,
                    onUpgrade: onUpgrade,
                    onOpenDecorations: onOpenDecorations,
                  ),
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
  const _TrainCabin({
    required this.state,
    required this.onUpgrade,
    required this.onOpenDecorations,
  });

  final GameState state;
  final ValueChanged<SlotKind> onUpgrade;
  final VoidCallback onOpenDecorations;

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
                    _DecorationManagerTile(
                      state: state,
                      onTap: onOpenDecorations,
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
  });

  final UpgradeSlot slot;
  final double gold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final affordable = gold >= slot.nextCost && !slot.isMaxed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 164,
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

class _DecorationManagerTile extends StatelessWidget {
  const _DecorationManagerTile({required this.state, required this.onTap});

  final GameState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 156,
          decoration: BoxDecoration(
            color: const Color(0xFF7A9D54).withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF7A9D54), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A9D54),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.local_florist_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '장식 관리',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF273735),
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('배치 ${state.placedDecorationCount}/3'),
                      const SizedBox(height: 8),
                      const Text(
                        '구매, 자동 배치, 업그레이드',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF56704E),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DecorationPanel extends StatelessWidget {
  const _DecorationPanel({
    required this.state,
    required this.onBuy,
    required this.onUpgrade,
  });

  final GameState state;
  final void Function(DecorationSlotKind slotKind, DecorationItem item) onBuy;
  final ValueChanged<DecorationSlotKind> onUpgrade;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Color(0xFFF9F3E9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      '장식 상점',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF243B3A),
                      ),
                    ),
                  ),
                  _CurrencyPill(
                    icon: Icons.confirmation_number_rounded,
                    label: '${state.gold.floor()} G',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '빈 위치에는 장식을 사고, 배치된 장식은 바로 업그레이드합니다.',
                style: TextStyle(color: Color(0xFF65706C)),
              ),
              const SizedBox(height: 16),
              for (final slotKind in DecorationSlotKind.values) ...[
                _DecorationSlotSection(
                  slotKind: slotKind,
                  state: state,
                  onBuy: onBuy,
                  onUpgrade: onUpgrade,
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DecorationSlotSection extends StatelessWidget {
  const _DecorationSlotSection({
    required this.slotKind,
    required this.state,
    required this.onBuy,
    required this.onUpgrade,
  });

  final DecorationSlotKind slotKind;
  final GameState state;
  final void Function(DecorationSlotKind slotKind, DecorationItem item) onBuy;
  final ValueChanged<DecorationSlotKind> onUpgrade;

  @override
  Widget build(BuildContext context) {
    final placed = state.decorations[slotKind];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(slotKind.icon, color: const Color(0xFF28413D)),
                const SizedBox(width: 8),
                Text(
                  slotKind.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: Color(0xFF28413D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (placed == null)
              for (final item in DecorationCatalog.forSlot(slotKind))
                _DecorationShopRow(
                  item: item,
                  gold: state.gold,
                  onPressed: () => onBuy(slotKind, item),
                )
            else
              _PlacedDecorationRow(
                placed: placed,
                gold: state.gold,
                onUpgrade: () => onUpgrade(slotKind),
              ),
          ],
        ),
      ),
    );
  }
}

class _DecorationShopRow extends StatelessWidget {
  const _DecorationShopRow({
    required this.item,
    required this.gold,
    required this.onPressed,
  });

  final DecorationItem item;
  final double gold;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final affordable = gold >= item.baseCost;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          _DecorationIcon(item: item),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '+${item.incomePerLevel.toStringAsFixed(1)} G/s  매력 +${item.appealPerLevel}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          FilledButton.tonal(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              foregroundColor: affordable
                  ? const Color(0xFF0F705F)
                  : const Color(0xFF8B7E6E),
            ),
            child: Text('${item.baseCost} G'),
          ),
        ],
      ),
    );
  }
}

class _PlacedDecorationRow extends StatelessWidget {
  const _PlacedDecorationRow({
    required this.placed,
    required this.gold,
    required this.onUpgrade,
  });

  final PlacedDecoration placed;
  final double gold;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final item = DecorationCatalog.byId(placed.itemId);
    final isMaxed = placed.level >= 10;
    final cost = item.costForLevel(placed.level);
    final affordable = gold >= cost && !isMaxed;

    return Row(
      children: [
        _DecorationIcon(item: item),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.name} Lv.${placed.level}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              Text(
                '+${(item.incomePerLevel * placed.level).toStringAsFixed(1)} G/s  매력 +${item.appealPerLevel * placed.level}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        FilledButton(
          onPressed: isMaxed ? null : onUpgrade,
          style: FilledButton.styleFrom(
            backgroundColor: affordable ? null : const Color(0xFFE4DED2),
            foregroundColor: affordable ? null : const Color(0xFF8B7E6E),
          ),
          child: Text(isMaxed ? 'MAX' : '$cost G'),
        ),
      ],
    );
  }
}

class _DecorationIcon extends StatelessWidget {
  const _DecorationIcon({required this.item});

  final DecorationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(item.icon, color: Colors.white),
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
