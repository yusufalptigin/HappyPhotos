import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:happy_photos/onBoardComponents/body.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class onBoard extends StatefulWidget {
  @override
  _onBoardState createState() => _onBoardState();
}

class _onBoardState extends State<onBoard> {

  Future<void> setupOneSignal() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("6f3c5e32-48c5-4026-a371-64ec03beb991");
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    setupOneSignal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(),
    );
  }
}
