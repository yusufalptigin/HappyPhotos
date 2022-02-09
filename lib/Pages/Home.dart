import 'dart:io' as Io;
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:happy_photos/services/ad_state.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:image_fade/image_fade.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:happy_photos/Pages/imageChange.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BannerAd banner;
  Timer _timer;
  static const duration = const Duration(seconds: 4);
  int index = 0, initCrashlytics;
  Io.File _image;
  final picker = ImagePicker();

  Future<bool> _checkListString() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('listString') ?? null;
    if(listString == null) return true;
    else return false;
  }

  Future _openCamera() async {
    Navigator.of(context).pop();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = Io.File(pickedFile.path);
      Future.delayed(Duration(milliseconds: 0)).then(
            (value) => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditPhotoScreen(image:_image),
          ),
        ),
      );
    }
  }

  Future _openGallery() async {
    Navigator.of(context).pop();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = Io.File(pickedFile.path);
      });
      Future.delayed(Duration(milliseconds: 400)).then(
            (value) => Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => EditPhotoScreen(image:_image),
          ),
        ),
      );
    }
  }

  void showChoice() {
    showCupertinoModalPopup(
        context: context,
        builder: (cxt) {
          return CupertinoActionSheet(
            actions: [
              CupertinoActionSheetAction(
                child: Text(
                  AppLocalizations.of(context).translate("Kamera"),
                  style: TextStyle(color: Colors.blue),),
                onPressed: () {
                  _openCamera();
                },
              ),
              CupertinoActionSheetAction(
                child: Text(
                  AppLocalizations.of(context).translate("Galeri"),
                  style: TextStyle(color: Colors.blue),),
                onPressed: () {
                  _openGallery();
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: Text(
                AppLocalizations.of(context).translate("İptal"),
                style: TextStyle(color: Colors.blue),),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          );
        }
     );
  }

  void _handleTick() async {setState(() {index = (index + 1) % 5;});}

  var images = [
    AssetImage("images/14hafta.jpg"),
    AssetImage('images/27hafta.jpg'),
    AssetImage('images/32hafta.jpg'),
    AssetImage('images/kız.jpg'),
    AssetImage('images/6ay.jpg')
  ];

  Future<int> _getCrashlytics() async {
    final prefs = await SharedPreferences.getInstance();
    final init = prefs.getInt('crashlytics') ?? 0;
    return init;
  }

  Future<void> _setCrashlytics() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('crashlytics', 1);
  }

  Future<void> asyncMethod() async {
    initCrashlytics = await _getCrashlytics();
    if(initCrashlytics == 0) _setCrashlytics();
    else{
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      setupOneSignal();
    }
  }

  Future<void> setupOneSignal() async {
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setAppId("6f3c5e32-48c5-4026-a371-64ec03beb991");
  }

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    final adState = Provider.of<AdState>(context);
    adState.initilization.then((status) {
      setState(() {
        banner = BannerAd(
            size: AdSize.banner,
            adUnitId: adState.bannerAdUnitId,
            listener: adState.getBannerAdListener,
            request: AdRequest()
        )..load();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    asyncMethod();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    _timer = null;
    banner.dispose();
  }

  Widget build(BuildContext context) {
    if (_timer == null) {
      _timer = Timer.periodic(duration, (Timer t) {
        _handleTick();
      });
    }
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - AdSize.banner.height,
            child: Stack(
              children: [
                Container(
                  child: ImageFade(
                    fit: BoxFit.fill,
                    height: double.infinity,
                    width: double.infinity,
                    alignment: Alignment.center,
                    image: images[index],
                  ),
                ),
                Column(
                  children: [
                    Column(
                      children: [

                      ],
                    ),
                    Spacer(flex: 18,),
                    Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(40,0,40,0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon: Image.asset('images/add.png'),
                                        color: Colors.white,
                                        onPressed: showChoice),
                                    Text(
                                      AppLocalizations.of(context).translate("Yeni"),
                                      style: TextStyle(color: Colors.white),)
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon: Image.asset('images/more.png'),
                                        onPressed: () async {
                                          bool x = await _checkListString();
                                          if(x == true) Navigator.pushReplacementNamed(context, '/historyDefault');
                                          else Navigator.pushReplacementNamed(context, '/history');
                                        }),
                                    Text(
                                        AppLocalizations.of(context).translate("Geçmiş"),
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                VerticalDivider(
                                  color: Colors.white,
                                  indent: 10,
                                  endIndent: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                        icon: Image.asset('images/past.png'),
                                        onPressed: () async {Navigator.pushReplacementNamed(context, '/more');}
                                    ),
                                    Text(
                                        AppLocalizations.of(context).translate("Daha Fazla"),
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                    ),
                    Spacer(flex: 3,),
                  ],
                )
              ],
            ),
          ),
          if(banner == null) Container(height: AdSize.banner.height.toDouble())
          else Container(
            color: Colors.white,
            height: AdSize.banner.height.toDouble(),
            width: MediaQuery.of(context).size.width,
            child: AdWidget(ad: banner),
          )
        ],
      )
    );
  }
}


