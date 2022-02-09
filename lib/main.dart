import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:happy_photos/Pages/Home.dart';
import 'package:happy_photos/Pages/more.dart';
import 'package:happy_photos/services/ad_state.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:happy_photos/Pages/imageChange.dart';
import 'package:happy_photos/Pages/onBoard.dart';
import 'package:happy_photos/Pages/History.dart';
import 'package:flutter/services.dart';
import 'Pages/historyDefault.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<int> _getInitScreen() async {
  final prefs = await SharedPreferences.getInstance();
  final steps = prefs.getInt('initScreen') ?? 0;
  return steps;
}

int initScreen;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initScreen = await _getInitScreen();
  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);
  runApp(Provider.value(
    value: adState,
    builder: (context, child) => App(),
  ));
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  final Future<FirebaseApp> _init = Firebase.initializeApp();
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return FutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Error();
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            supportedLocales: [
              const Locale('en', 'US'),
              const Locale('tr', 'TR'),
            ],

            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            initialRoute: initScreen == 0 ? '/onboard' : '/home',
            routes: {
              '/onboard': (context) => onBoard(),
              '/home': (context) => HomePage(),
              '/more': (context) => More(),
              '/imageChange': (context) => EditPhotoScreen(),
              '/historyDefault': (context) => HistoryDefault(),
              '/history': (context) => History(),
            },
          );
        }
        else return Loading();
      },
    );
  }
}

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image(image: ExactAssetImage("images/loading.png")),
    );
  }
}

class Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Image(image: ExactAssetImage("images/loading.png")),
    );
  }
}

