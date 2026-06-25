import 'dart:async';

import 'package:flutter/material.dart';

import '../data/balance_config.dart';
import '../models/ad_reward.dart';
import '../models/decoration.dart';
import '../models/game_state.dart';
import '../models/movement_checkpoint.dart';
import '../models/offline_reward.dart';
import '../models/slot_kind.dart';
import '../models/upgrade_slot.dart';
import '../services/game_storage.dart';
import '../services/location_service.dart';
import '../services/monetization_service.dart';
import '../services/movement_reward_calculator.dart';
import '../widgets/bottom_actions.dart';
import '../widgets/decoration_panel.dart';
import '../widgets/game_header.dart';
import '../widgets/movement_bonus_sheet.dart';
import '../widgets/offline_reward_sheet.dart';
import '../widgets/shop_sheet.dart';
import '../widgets/status_panel.dart';
import '../widgets/train_cabin.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    this.locationService = const GeolocatorLocationService(),
    this.monetizationService = const FakeMonetizationService(),
    super.key,
  });

  final LocationService locationService;
  final MonetizationService monetizationService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  final _storage = GameStorage();
  GameState? _state;
  Timer? _incomeTimer;
  Timer? _saveTimer;
  String? _toast;
  bool _locationBusy = false;
  bool _monetizationBusy = false;

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

  Future<void> _claimOfflineGold({required bool doubled}) async {
    final current = _state;
    if (current == null || current.pendingOfflineGold <= 0) {
      return;
    }

    if (doubled) {
      await _runRewardedAd(AdPlacement.offlineDouble);
    }

    final latest = _state;
    if (latest == null || latest.pendingOfflineGold <= 0) {
      return;
    }

    final reward = latest.pendingOfflineGold * (doubled ? 2 : 1);
    setState(() {
      _state = latest.copyWith(
        gold: latest.gold + reward,
        pendingOfflineGold: 0,
        offlineReward: _emptyOfflineReward(latest.offlineReward),
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
              locationBusy: _locationBusy,
              onSettleGpsMove: () async {
                final future = _settleGpsMove();
                setModalState(() {});
                await future;
                setModalState(() {});
              },
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

  void _openShopSheet() {
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

            return ShopSheet(
              state: current,
              monetizationBusy: _monetizationBusy,
              onClaimSupportAd: () async {
                final future = _claimSupportAdReward();
                setModalState(() {});
                await future;
                setModalState(() {});
              },
              onPurchaseVipPass: () async {
                final future = _purchaseVipPass();
                setModalState(() {});
                await future;
                setModalState(() {});
              },
            );
          },
        );
      },
    );
  }

  Future<void> _claimSupportAdReward() async {
    final current = _state;
    if (current == null || _monetizationBusy) {
      return;
    }

    final reward = await _runRewardedAd(AdPlacement.supportGrant);
    if (reward == null) {
      return;
    }

    final latest = _state;
    if (latest == null) {
      return;
    }

    setState(() {
      _state = latest.copyWith(gold: latest.gold + reward.gold);
      _toast = '긴급 지원금 지급: +${reward.gold} G';
    });
    _save();
  }

  Future<AdReward?> _runRewardedAd(AdPlacement placement) async {
    final current = _state;
    if (current == null || _monetizationBusy) {
      return null;
    }

    if (current.monetization.adsRemoved) {
      setState(() {
        _state = current.copyWith(
          monetization: current.monetization.copyWith(
            rewardedAdsWatched: current.monetization.rewardedAdsWatched + 1,
          ),
        );
      });
      return AdReward(
        placement: placement,
        gold: placement == AdPlacement.supportGrant
            ? BalanceConfig.adGrantGold
            : 0,
        message: 'VIP 광고 스킵',
      );
    }

    setState(() {
      _monetizationBusy = true;
      _toast = '광고 테스트 재생 중...';
    });

    try {
      final reward = await widget.monetizationService.showRewardedAd(placement);
      if (!mounted) {
        return null;
      }

      final latest = _state;
      if (latest == null) {
        return null;
      }

      setState(() {
        _state = latest.copyWith(
          monetization: latest.monetization.copyWith(
            rewardedAdsWatched: latest.monetization.rewardedAdsWatched + 1,
          ),
        );
        _toast = reward.message;
      });
      return reward;
    } finally {
      if (mounted) {
        setState(() => _monetizationBusy = false);
      }
    }
  }

  Future<void> _purchaseVipPass() async {
    final current = _state;
    if (current == null ||
        _monetizationBusy ||
        current.monetization.vipPassActive) {
      return;
    }

    setState(() {
      _monetizationBusy = true;
      _toast = 'VIP 패스 결제 테스트 중...';
    });

    try {
      final purchased = await widget.monetizationService.purchaseVipPass();
      if (!mounted || !purchased) {
        return;
      }

      final latest = _state;
      if (latest == null) {
        return;
      }

      setState(() {
        _state = latest.copyWith(
          monetization: latest.monetization.copyWith(
            vipPassActive: true,
            adsRemoved: true,
          ),
        );
        _toast = 'VIP 패스 활성화 완료';
      });
      _save();
    } finally {
      if (mounted) {
        setState(() => _monetizationBusy = false);
      }
    }
  }

  Future<void> _settleGpsMove() async {
    final current = _state;
    if (current == null || _locationBusy) {
      return;
    }

    setState(() {
      _locationBusy = true;
      _toast = '현재 위치 확인 중...';
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      final nextCheckpoint = MovementCheckpoint(
        latitude: location.latitude,
        longitude: location.longitude,
        recordedAt: location.capturedAt,
      );

      final latest = _state;
      if (latest == null) {
        return;
      }

      if (!latest.movementCheckpoint.hasLocation) {
        setState(() {
          _state = latest.copyWith(movementCheckpoint: nextCheckpoint);
          _toast = '출발역 등록 완료. 다음 도착역부터 정산됩니다';
        });
        await _save();
        return;
      }

      final checkpoint = latest.movementCheckpoint;
      final distanceMeters = widget.locationService.distanceBetweenMeters(
        startLatitude: checkpoint.latitude!,
        startLongitude: checkpoint.longitude!,
        endLatitude: location.latitude,
        endLongitude: location.longitude,
      );
      final report = MovementRewardCalculator.fromCheckpoint(
        checkpoint: checkpoint,
        currentLocation: location,
        distanceKm: distanceMeters / 1000,
        screenOnBoost: latest.focusBoostEnabled,
      );

      setState(() {
        _state = latest.copyWith(
          gold: latest.gold + report.gold,
          warpPoints: latest.warpPoints + report.warpPoints,
          movementCheckpoint: nextCheckpoint,
          lastMovementReport: report.hasReward
              ? report
              : latest.lastMovementReport,
        );
        _toast = report.hasReward
            ? '도착역 정산: +${report.gold} G / +${report.warpPoints} WP'
            : '도착역이 가까워 출발역만 갱신했습니다';
      });
      await _save();
    } on LocationServiceException catch (error) {
      if (mounted) {
        setState(() => _toast = error.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _toast = '현재 위치를 가져오지 못했습니다');
      }
    } finally {
      if (mounted) {
        setState(() => _locationBusy = false);
      }
    }
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
      _toast = '테스트 운행 정산: +${report.gold} G / +${report.warpPoints} WP';
    });
    _save();
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
                onOpenShop: _openShopSheet,
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
    required this.onOpenShop,
  });

  final GameState state;
  final String? toast;
  final ValueChanged<SlotKind> onUpgrade;
  final VoidCallback onOpenDecorations;
  final ValueChanged<bool> onToggleFocusBoost;
  final VoidCallback onOpenMovementBonus;
  final VoidCallback onOpenShop;

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
                      onShop: onOpenShop,
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
