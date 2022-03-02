import 'dart:io';

class AdHelper {

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-4681060581165022/1904563636";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4681060581165022/5596751852";
    } else {
      throw new UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-4681060581165022/6997663127";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4681060581165022/3058418113";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-4681060581165022/1129555476";
    } else if (Platform.isIOS) {
      return "ca-app-pub-4681060581165022/9746412095";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}