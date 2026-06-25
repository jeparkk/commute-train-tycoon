import 'package:flutter/material.dart';

import '../data/balance_config.dart';
import '../models/game_state.dart';

class ShopSheet extends StatelessWidget {
  const ShopSheet({
    required this.state,
    required this.monetizationBusy,
    required this.onClaimSupportAd,
    required this.onPurchaseVipPass,
    super.key,
  });

  final GameState state;
  final bool monetizationBusy;
  final VoidCallback onClaimSupportAd;
  final VoidCallback onPurchaseVipPass;

  @override
  Widget build(BuildContext context) {
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
              const Row(
                children: [
                  _ShopIcon(icon: Icons.storefront_rounded),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '상점',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF243B3A),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          '광고와 VIP 패스 구조 테스트',
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
              _VipPassCard(
                active: state.monetization.vipPassActive,
                adsRemoved: state.monetization.adsRemoved,
                monetizationBusy: monetizationBusy,
                onPurchaseVipPass: onPurchaseVipPass,
              ),
              const SizedBox(height: 12),
              _AdRewardCard(
                adsRemoved: state.monetization.adsRemoved,
                watchedCount: state.monetization.rewardedAdsWatched,
                monetizationBusy: monetizationBusy,
                onClaimSupportAd: onClaimSupportAd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VipPassCard extends StatelessWidget {
  const _VipPassCard({
    required this.active,
    required this.adsRemoved,
    required this.monetizationBusy,
    required this.onPurchaseVipPass,
  });

  final bool active;
  final bool adsRemoved;
  final bool monetizationBusy;
  final VoidCallback onPurchaseVipPass;

  @override
  Widget build(BuildContext context) {
    return _ShopCard(
      icon: Icons.workspace_premium_rounded,
      title: '출퇴근 VIP 패스',
      subtitle: active ? '활성화됨' : '월 구독 결제 SDK 자리',
      children: [
        _ShopMetaRow(
          icon: Icons.block_rounded,
          label: '광고 제거',
          value: adsRemoved ? '적용' : '미적용',
        ),
        const SizedBox(height: 8),
        const _ShopMetaRow(
          icon: Icons.savings_rounded,
          label: '오프라인 금고',
          value: '12시간',
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: active || monetizationBusy ? null : onPurchaseVipPass,
          icon: const Icon(Icons.card_membership_rounded),
          label: Text(active ? 'VIP 적용 완료' : 'VIP 패스 테스트 구매'),
        ),
      ],
    );
  }
}

class _AdRewardCard extends StatelessWidget {
  const _AdRewardCard({
    required this.adsRemoved,
    required this.watchedCount,
    required this.monetizationBusy,
    required this.onClaimSupportAd,
  });

  final bool adsRemoved;
  final int watchedCount;
  final bool monetizationBusy;
  final VoidCallback onClaimSupportAd;

  @override
  Widget build(BuildContext context) {
    return _ShopCard(
      icon: Icons.ondemand_video_rounded,
      title: '광고 보상',
      subtitle: adsRemoved ? 'VIP는 광고 없이 테스트 보상 지급' : 'SDK 연결 전 rewarded ad 자리',
      children: [
        _ShopMetaRow(
          icon: Icons.payments_rounded,
          label: '긴급 지원금',
          value: '+${BalanceConfig.adGrantGold} G',
        ),
        const SizedBox(height: 8),
        _ShopMetaRow(
          icon: Icons.visibility_rounded,
          label: '광고 보상 횟수',
          value: '$watchedCount회',
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: monetizationBusy ? null : onClaimSupportAd,
          icon: const Icon(Icons.play_circle_rounded),
          label: Text(adsRemoved ? '광고 없이 지원금 받기' : '광고 보고 지원금 받기'),
        ),
      ],
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE1D8C8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _ShopIcon(icon: icon, small: true),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF243B3A),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF65706C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ShopIcon extends StatelessWidget {
  const _ShopIcon({required this.icon, this.small = false});

  final IconData icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: small ? 38 : 58,
      height: small ? 38 : 58,
      decoration: BoxDecoration(
        color: const Color(0xFF7A654B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.white, size: small ? 22 : 32),
    );
  }
}

class _ShopMetaRow extends StatelessWidget {
  const _ShopMetaRow({
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
