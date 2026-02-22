import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  static const Duration _interstitialCooldown = Duration(minutes: 3);

  bool _initialized = false;
  bool _loadingInterstitial = false;
  bool _loadingRewarded = false;
  DateTime? _lastInterstitialShown;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool get _supported => !kIsWeb && Platform.isAndroid;

  Future<void> initialize() async {
    if (!_supported || _initialized) {
      return;
    }

    await MobileAds.instance.initialize();
    _initialized = true;
    await _loadInterstitial();
    await _loadRewarded();
  }

  Future<void> showInterstitial() async {
    if (!_supported) {
      return;
    }
    await initialize();

    final DateTime now = DateTime.now();
    final DateTime? last = _lastInterstitialShown;
    if (last != null && now.difference(last) < _interstitialCooldown) {
      return;
    }

    final InterstitialAd? ad = _interstitialAd;
    if (ad == null) {
      await _loadInterstitial();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd dismissedAd) {
        dismissedAd.dispose();
        _interstitialAd = null;
        unawaited(_loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (
        InterstitialAd failedAd,
        AdError error,
      ) {
        failedAd.dispose();
        _interstitialAd = null;
        unawaited(_loadInterstitial());
      },
    );

    _lastInterstitialShown = now;
    ad.show();
  }

  Future<void> showRewarded(void Function() onRewarded) async {
    if (!_supported) {
      return;
    }
    await initialize();

    final RewardedAd? ad = _rewardedAd;
    if (ad == null) {
      await _loadRewarded();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd dismissedAd) {
        dismissedAd.dispose();
        _rewardedAd = null;
        unawaited(_loadRewarded());
      },
      onAdFailedToShowFullScreenContent: (RewardedAd failedAd, AdError error) {
        failedAd.dispose();
        _rewardedAd = null;
        unawaited(_loadRewarded());
      },
    );

    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewarded();
    });
  }

  Future<void> dispose() async {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  Future<void> _loadInterstitial() async {
    if (_loadingInterstitial || !_supported) {
      return;
    }

    _loadingInterstitial = true;
    final Completer<void> completer = Completer<void>();

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _loadingInterstitial = false;
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _loadingInterstitial = false;
          completer.complete();
        },
      ),
    );

    await completer.future;
  }

  Future<void> _loadRewarded() async {
    if (_loadingRewarded || !_supported) {
      return;
    }

    _loadingRewarded = true;
    final Completer<void> completer = Completer<void>();

    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          _loadingRewarded = false;
          completer.complete();
        },
        onAdFailedToLoad: (LoadAdError error) {
          _loadingRewarded = false;
          completer.complete();
        },
      ),
    );

    await completer.future;
  }
}
