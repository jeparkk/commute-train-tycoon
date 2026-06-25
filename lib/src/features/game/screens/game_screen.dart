import 'dart:async';

import 'package:flutter/material.dart';

import '../data/balance_config.dart';
import '../models/decoration.dart';
import '../models/game_state.dart';
import '../models/offline_reward.dart';
import '../models/slot_kind.dart';
import '../models/upgrade_slot.dart';
import '../services/game_storage.dart';
import '../services/movement_reward_calculator.dart';
import '../widgets/bottom_actions.dart';
import '../widgets/decoration_panel.dart';
import '../widgets/game_header.dart';
import '../widgets/movement_bonus_sheet.dart';
import '../widgets/offline_reward_sheet.dart';
import '../widgets/status_panel.dart';
import '../widgets/train_cabin.dart';

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

    if (loaded.offlineReward.hasReward) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOfflineRewardSheet();
      });
    }
  }

  Future<void> _save() async {
    final current = _state;
    if (current == null) {
      return;
    }

    final saveState = current.pendingOfflineGold > 0
        ? current
        : current.copyWith(lastSavedAt: DateTime.now());

    await _storage.save(saveState);
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
        offlineReward: _emptyOfflineReward(current.offlineReward),
        lastSavedAt: DateTime.now(),
      );
      _toast = doubled ? '광고 정산 테스트: 보상 2배!' : '오프라인 보상 수금 완료';
    });
    _save();
  }

  void _showOfflineRewardSheet() {
    final current = _state;
    if (current == null || !current.offlineReward.hasReward || !mounted) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return OfflineRewardSheet(
          reward: current.offlineReward,
          onClaim: ({required doubled}) {
            Navigator.of(sheetContext).pop();
            _claimOfflineGold(doubled: doubled);
          },
        );
      },
    );
  }

  OfflineReward _emptyOfflineReward(OfflineReward reward) {
    return OfflineReward(
      gold: 0,
      duration: Duration.zero,
      maxDuration: reward.maxDuration,
      efficiency: reward.efficiency,
    );
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

            return DecorationPanel(
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
    if (placed.level >= BalanceConfig.maxDecorationLevel) {
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

  void _openMovementBonusSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final current = _state;
            if (current == null) {
              return const SizedBox.shrink();
            }

            return MovementBonusSheet(
              state: current,
              onSettleDemoMove: () {
                _settleDemoMove();
                setModalState(() {});
              },
            );
          },
        );
      },
    );
  }

  void _settleDemoMove() {
    final current = _state;
    if (current == null) {
      return;
    }

    final report = MovementRewardCalculator.demoCommute(
      screenOnBoost: current.focusBoostEnabled,
    );
    setState(() {
      _state = current.copyWith(
        gold: current.gold + report.gold,
        warpPoints: current.warpPoints + report.warpPoints,
        lastMovementReport: report,
      );
      _toast = '이동 정산 완료: +${report.gold} G / +${report.warpPoints} WP';
    });
    _save();
  }

  void _showComingSoon(String feature) {
    setState(() {
      _toast = '$feature은 다음 단계에서 열립니다';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;

    return Scaffold(
      body: SafeArea(
        child: state == null
            ? const Center(child: CircularProgressIndicator())
            : _GameContent(
                state: state,
                toast: _toast,
                onUpgrade: _upgrade,
                onOpenDecorations: _openDecorationPanel,
                onToggleFocusBoost: _toggleFocusBoost,
                onOpenMovementBonus: _openMovementBonusSheet,
                onShowComingSoon: _showComingSoon,
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
    required this.onOpenMovementBonus,
    required this.onShowComingSoon,
  });

  final GameState state;
  final String? toast;
  final ValueChanged<SlotKind> onUpgrade;
  final VoidCallback onOpenDecorations;
  final ValueChanged<bool> onToggleFocusBoost;
  final VoidCallback onOpenMovementBonus;
  final ValueChanged<String> onShowComingSoon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF2E7D4), Color(0xFFEAF5F2)],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GameHeader(state: state),
                    const SizedBox(height: 12),
                    StatusPanel(
                      state: state,
                      onToggleFocusBoost: onToggleFocusBoost,
                    ),
                    const SizedBox(height: 12),
                    TrainCabin(
                      state: state,
                      onUpgrade: onUpgrade,
                      onOpenDecorations: onOpenDecorations,
                    ),
                    const SizedBox(height: 12),
                    BottomActions(
                      toast: toast,
                      onCabin: () {},
                      onMove: onOpenMovementBonus,
                      onShop: () => onShowComingSoon('상점'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
