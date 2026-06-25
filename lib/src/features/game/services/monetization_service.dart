import '../data/balance_config.dart';
import '../models/ad_reward.dart';

abstract class MonetizationService {
  Future<AdReward> showRewardedAd(AdPlacement placement);

  Future<bool> purchaseVipPass();
}

class FakeMonetizationService implements MonetizationService {
  const FakeMonetizationService();

  @override
  Future<AdReward> showRewardedAd(AdPlacement placement) async {
    return AdReward(
      placement: placement,
      gold: placement == AdPlacement.supportGrant
          ? BalanceConfig.adGrantGold
          : 0,
      message: '${placement.label} 테스트 완료',
    );
  }

  @override
  Future<bool> purchaseVipPass() async {
    return true;
  }
}
