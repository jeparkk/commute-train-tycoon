class MonetizationState {
  const MonetizationState({
    required this.vipPassActive,
    required this.adsRemoved,
    required this.rewardedAdsWatched,
  });

  const MonetizationState.initial()
    : vipPassActive = false,
      adsRemoved = false,
      rewardedAdsWatched = 0;

  final bool vipPassActive;
  final bool adsRemoved;
  final int rewardedAdsWatched;

  bool get canShowAds => !adsRemoved;

  MonetizationState copyWith({
    bool? vipPassActive,
    bool? adsRemoved,
    int? rewardedAdsWatched,
  }) {
    return MonetizationState(
      vipPassActive: vipPassActive ?? this.vipPassActive,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      rewardedAdsWatched: rewardedAdsWatched ?? this.rewardedAdsWatched,
    );
  }
}
