import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdState{
  Future<InitializationStatus> initilization;

  AdState(this.initilization);

  String get bannerAdUnitId => 'ca-app-pub-3940256099942544/6300978111';
  String get interstitialVideoAdUnitId => 'ca-app-pub-3940256099942544/8691691433';
  String get openAppAdUnitId => 'ca-app-pub-3940256099942544/3419835294';

  BannerAdListener get getBannerAdListener => _getBannerAdListener;

  BannerAdListener get _getBannerAdListener => BannerAdListener(
    onAdLoaded: (Ad ad) {
      print('$BannerAd loaded.');
    },
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      print('$BannerAd failedToLoad: $error');
      ad.dispose();
    },
    onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
    onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
  );

}