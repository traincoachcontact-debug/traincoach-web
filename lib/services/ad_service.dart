// lib/services/ad_service.dart
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kIsWeb
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // IDs de Unidades de Anuncios de PRUEBA de AdMob.
  // ¡REEMPLAZA con tus propios IDs para producción!
  bool get isMobilePlatform => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;

  InterstitialAd? _interstitialAd;
  int _interstitialLoadAttempts = 0;
  final int _maxInterstitialLoadAttempts = 3;

  int _screenChangeCount = 0;
  final int _interstitialAdFrequency = 6; // Mostrar cada 6 cambios

  Function? _onBannerAdLoadedCallback;

  Future<void> initialize() async {
        if (isMobilePlatform) {
      await MobileAds.instance.initialize();
    } else {
      print("Ad Service: Plataforma no soportada (Windows/Desktop). No se inicializarán los anuncios.");
    }
  }

  void loadBannerAd(Function onLoaded) {
    if (!isMobilePlatform) return;
    _onBannerAdLoadedCallback = onLoaded;
    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner, // Tamaño estándar de banner
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('$ad loaded.');
          _isBannerAdLoaded = true;
          _onBannerAdLoadedCallback?.call();
        },
        onAdFailedToLoad: (ad, err) {
          print('BannerAd failed to load: $err');
          ad.dispose();
        },
      ),
    )..load();
  }

  BannerAd? get bannerAd => _bannerAd;
  bool get isBannerAdLoaded => _isBannerAdLoaded;

  void loadInterstitialAd() {
    if (!isMobilePlatform) return;
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0; // Resetear intentos al cargar exitosamente
          print('InterstitialAd loaded.');
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) =>
                print('$ad onAdShowedFullScreenContent.'),
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print('$ad onAdDismissedFullScreenContent.');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Cargar el siguiente
            },
            onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
              print('$ad onAdFailedToShowFullScreenContent: $error');
              ad.dispose();
              _interstitialAd = null;
              loadInterstitialAd(); // Intentar cargar otro
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          print('InterstitialAd failed to load: $error. Attempts: $_interstitialLoadAttempts');
          if (_interstitialLoadAttempts <= _maxInterstitialLoadAttempts) {
            loadInterstitialAd(); // Intentar cargar de nuevo si no se superan los intentos
          }
        },
      ),
    );
  }

  void showInterstitialAdIfReady() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      // El _interstitialAd se vuelve null y se recarga en onAdDismissedFullScreenContent
    } else {
      print('InterstitialAd not ready yet.');
      loadInterstitialAd(); // Asegurarse de que se está cargando uno
    }
  }

  void incrementScreenChangeAndShowAd() {
    _screenChangeCount++;
    print("Screen change count: $_screenChangeCount");
    if (_screenChangeCount % _interstitialAdFrequency == 0) {
      print("Interstitial ad frequency met. Attempting to show ad.");
      showInterstitialAdIfReady();
    }
  }

  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void disposeInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
