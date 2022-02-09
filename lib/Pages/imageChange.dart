import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:happy_photos/services/photos.dart';
import 'package:happy_photos/services/stickers.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart';
import 'package:image/image.dart' as imageLib;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sticker extends StatefulWidget {

  final String item;
  Sticker({Key key, this.item}): super(key: key);
  @override
  _StickerState createState() => _StickerState();
}

class _StickerState extends State<Sticker> {

  bool flag = false;
  final ValueNotifier<Matrix4> notifier = ValueNotifier(Matrix4.identity());
  Color currentColor = Colors.white;
  void changeColor(Color color) {setState(() => currentColor = color);}

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return flag ? Container(width: 0,height: 0) : Positioned.fill(
      child: GestureDetector(
        onLongPress: (){
          showGeneralDialog(
            barrierLabel: "Label",
            barrierDismissible: true,
            barrierColor: Colors.white.withOpacity(0),
            transitionDuration: Duration(milliseconds: 700),
            context: context,
            pageBuilder: (context, anim1, anim2) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    height: (200 / 812.0) * MediaQuery.of(context).size.height,
                    child: SizedBox.expand(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SingleChildScrollView(
                              child: SlidePicker(
                                pickerColor: Colors.blue,
                                onColorChanged: changeColor,
                                paletteType: PaletteType.hsv,
                                enableAlpha: false,
                                displayThumbColor: true,
                                showLabel: false,
                                showIndicator: false,
                                indicatorBorderRadius:
                                const BorderRadius.vertical(
                                  top: const Radius.circular(25.0),
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    margin: EdgeInsets.only(bottom: 12, left: 12, right: 12, top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
              );
            },
            transitionBuilder: (context, anim1, anim2, child) {
              return SlideTransition(
                position: Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
                child: child,
              );
            },
          );
        },
        onDoubleTap: (){
          setState(() {
            flag = true;
          });
        },
        child: MatrixGestureDetector(
          onMatrixUpdate: (m, tm, sm, rm) {
            notifier.value = m;
          },
          child: AnimatedBuilder(
            animation: notifier,
            builder: (ctx, child) {
              return Transform(
                transform: notifier.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: (135 / 375) * MediaQuery.of(context).size.width,
                        height: (135 / 812.0) * MediaQuery.of(context).size.height,
                        child: Image.asset(widget.item, fit: BoxFit.contain,color: currentColor)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class EditPhotoScreen extends StatefulWidget {
  final File image;
  EditPhotoScreen({Key key, this.image}): super(key: key);
  @override
  _EditPhotoScreenState createState() => _EditPhotoScreenState();
}

class _EditPhotoScreenState extends State<EditPhotoScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey<ExtendedImageEditorState>();

  List<Filter> filters = presetFiltersList;
  final FocusNode focusNode = FocusNode();
  final CarouselController _controller = CarouselController();
  AnimationController _animationController;
  bool isPlaying = false, isClicked = false, isDisplaySticker = false, isDisplayFilters = false, cropped = false;
  File image;
  InterstitialAd _interstitialAd;
  int _numInterstitialLoadAttempts = 0, maxFailedLoadAttempts = 3, index;

  List<Widget> list = [];
  List<Photos> listPhotos = [];

  ScreenshotController screenshotController = ScreenshotController();

  final _filters = [
    Colors.transparent,
    Colors.white,
    Colors.white.withOpacity(0.25),
    ...List.generate(Colors.primaries.length, (index) => Colors.primaries[(index) % Colors.primaries.length].withOpacity(0.25)),
    Colors.white.withOpacity(0.5),
    ...List.generate(Colors.primaries.length, (index) => Colors.primaries[(index) % Colors.primaries.length].withOpacity(0.5)),
    Colors.white.withOpacity(0.75),
    ...List.generate(Colors.primaries.length, (index) => Colors.primaries[(index) % Colors.primaries.length].withOpacity(0.75)),
  ];

  final _filterColor = ValueNotifier<Color>(Colors.transparent);

  void _onFilterChanged(Color value) {_filterColor.value = value;}

  List<Widget> returnListFilters(BuildContext context){
    final List<Widget> filtersList = _filters.map((item) => Container(
      margin: EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: (){_onFilterChanged(item);},
        child: Image.asset(
            'images/colorBlend.jpeg',
            color: item,
            colorBlendMode: BlendMode.hardLight,
            fit: BoxFit.scaleDown
          ),
      ),
    )).toList();

    return filtersList;
  }

  List<Widget> returnList(BuildContext context){
    final List<Widget> stagesList = Stickers().stages.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: GestureDetector(
              onTap: (){
                setState(() {list.add(Sticker(item:item,));});
                if(list.length == 1) checkerFunction(context);
              },
              child: Image.asset(item, fit: BoxFit.fitWidth)),
        ),
      ),
    )).toList();

    final List<Widget> monthsList = Stickers().months.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: GestureDetector(
              onTap: (){
                setState(() {list.add(Sticker(item:item,));});
                if(list.length == 1) checkerFunction(context);
              },
              child: Image.asset(item, fit: BoxFit.fitWidth)),
        ),
      ),
    )).toList();

    final List<Widget> weeksList = Stickers().weeks.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: GestureDetector(
              onTap: (){
                setState(() {list.add(Sticker(item:item,));});
                if(list.length == 1) checkerFunction(context);
              },
              child: Image.asset(item, fit: BoxFit.fitWidth)),
        ),
      ),
    )).toList();

    final List<Widget> babyList = Stickers().baby.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: GestureDetector(
              onTap: (){
                setState(() {list.add(Sticker(item:item));});
                if(list.length == 1) checkerFunction(context);
              },
              child: Image.asset(item, fit: BoxFit.fitWidth)),
        ),
      ),
    )).toList();

    final List<Widget> variousList = Stickers().various.map((item) => Container(
      child: Container(
        margin: EdgeInsets.all(5.0),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
          child: GestureDetector(
              onTap: (){
                setState(() {list.add(Sticker(item:item));});
                if(list.length == 1) checkerFunction(context);
              },
              child: Image.asset(item, fit: BoxFit.fitWidth)),
        ),
      ),
    ),
    ).toList();
    if(index==0) return stagesList;
    else if(index==1) return monthsList;
    else if(index==2) return weeksList;
    else if(index==3) return babyList;
    else return variousList;
  }

  Future<bool> saveImage(Uint8List bytes) async {
    if(await _requestPermission(Permission.storage)){
      final time = DateTime.now().toIso8601String().replaceAll('.', '-').replaceAll(':', '-');
      final name = 'screenshot_$time';
      await ImageGallerySaver.saveImage(bytes, name: name);
      final prefs = await SharedPreferences.getInstance();
      String listString = await _getListString();
      if (listString != null) listPhotos = Photos.decodeItems(listString);
      //print(listPhotos);
      Photos photo = Photos(bytes: bytes);
      listPhotos.insert(0, photo);
      String listStringEncoded = Photos.encodeItems(listPhotos);
      //print(listStringEncoded);
      await prefs.setString('listString', listStringEncoded);
      return true;
    }
    else return false;
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) return true;
    else {
      var result = await permission.request();
      if (result == PermissionStatus.granted) return true;
    }
    return false;
  }

  Future shareImage(Uint8List bytes) async {
    final time = DateTime.now();
    final tempDir = await getTemporaryDirectory();
    final imageShare = await new File('${tempDir.path}/screenshot_$time.jpg').create();
    imageShare.writeAsBytesSync(bytes);
    //final directory = await getApplicationDocumentsDirectory();
    //final imageShare = File('${directory.path}/image.jpg'); // Sorun bu satırda
    //imageShare.writeAsBytesSync(bytes);
    await Share.shareFiles([imageShare.path], text: '');
    //ShareFilesAndScreenshotWidgets().shareFile("", "image.jpg", bytes, "image/jpg", text: "");
  }

  Future getImage(context) async {
    String fileName = basename(image.path);
    var imageFilter = imageLib.decodeImage(image.readAsBytesSync());
    Map imageFile = await Navigator.push(context,
      new MaterialPageRoute(
        builder: (context) => new PhotoFilterSelector(
          title: Text(AppLocalizations.of(context).translate("Filtreler")),
          image: imageFilter,
          filters: presetFiltersList,
          filename: fileName,
          loader: Center(child: CircularProgressIndicator()),
          fit: BoxFit.contain,
        ),
      ),
    );
    if (imageFile != null && imageFile.containsKey('image_filtered')) {setState(() {image = imageFile['image_filtered'];});}
  }

  Future<Null> _cropImage(BuildContext context) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: Platform.isAndroid
        ? [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
        ]
        : [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio5x3,
        CropAspectRatioPreset.ratio5x4,
        CropAspectRatioPreset.ratio7x5,
        CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: AppLocalizations.of(context).translate("Kırpıcı"),
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: AppLocalizations.of(context).translate("Kırpıcı"),
        ));
    if (croppedFile != null) {setState(() {image = croppedFile;});}
  }

  void setup(){image = widget.image;}

  /* void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-3940256099942544/8691691433',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        )
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd.show();
    _interstitialAd = null;
  } */

  @override
  void initState() {
    super.initState();
    setup();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    //_createInterstitialAd();
    focusNode.addListener(() { });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black.withOpacity(0.65),
            leading: IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              icon: Icon(Icons.arrow_back_ios, color: Colors.white,),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            actions: <Widget>[
              IconButton(
              splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Image.asset('images/cop.png'),
                onPressed:(){popUpTrash(context);},
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Image.asset('images/palet.png'),
                onPressed:(){popUpPalette(context);},
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Image.asset('images/crop.png'),
                onPressed: (){_cropImage(context);},
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Image.asset('images/save.png'),
                onPressed: () async {
                  double pixelRatio = MediaQuery.of(context).devicePixelRatio;
                  final image = await screenshotController.capture(pixelRatio: pixelRatio,delay: Duration(milliseconds: 10));
                  bool x = await saveImage(image);
                  if(x == true){
                    popUpTrue(context);
                    //_showInterstitialAd();
                  }
                  else popUpFalse(context);
                },
              ),
              IconButton(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                icon: Image.asset('images/trans.png'),
                onPressed: () async {
                  double pixelRatio = MediaQuery.of(context).devicePixelRatio;
                  final image = await screenshotController.capture(pixelRatio: pixelRatio,delay: Duration(milliseconds: 10));
                  await shareImage(image);
                },
              )
            ]
        ),
        body: Container(
          child: Column(
              children: <Widget>[
                Expanded(
                  flex: 10,
                  child: Screenshot(
                    controller: screenshotController,
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: AlignmentDirectional.center,
                      children: <Widget>[
                        Container(
                          child: ValueListenableBuilder(
                            valueListenable: _filterColor,
                            builder: (context, value, child) {
                              final color = value as Color;
                              return Image.file(
                                image,
                                color: color == Colors.transparent ? color : color,
                                colorBlendMode: BlendMode.color,
                                fit: BoxFit.fill,
                              );
                            },
                          ),
                        ),
                        for (Widget sticker in list) sticker,
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex:2,
                    child: isClicked ? isDisplayFilters ? Container(
                      color: Colors.black.withOpacity(0.65),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      icon: Image.asset('images/geri.png', color: Colors.amberAccent),
                                      onPressed: () {setState(() {isDisplayFilters = false;isClicked = false;});}
                                  ),
                                  Text(AppLocalizations.of(context).translate("Geri"),style: TextStyle(color: Colors.amberAccent))
                                ],
                              )
                          ),
                          ),
                          Expanded(flex: 5,child: CarouselSlider(
                            carouselController: _controller,
                            options: CarouselOptions(
                              viewportFraction: 0.2,
                              aspectRatio: 2.0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: false,
                              initialPage: 2,
                            ),
                            items: returnListFilters(context),
                          ))
                        ],
                      ),
                    ) : isDisplaySticker ? Container(
                      color: Colors.black.withOpacity(0.65),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(flex: 1, child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      icon: Image.asset('images/geri.png', color: Colors.amberAccent),
                                      onPressed: () {setState(() {isDisplaySticker = false;});}
                                  ),
                                  Text(AppLocalizations.of(context).translate("Geri"),style: TextStyle(color: Colors.amberAccent))
                                ],
                              )
                            ),
                          ),
                          Expanded(flex:5,child: CarouselSlider(
                            carouselController: _controller,
                            options: CarouselOptions(
                              viewportFraction: 0.2,
                              aspectRatio: 2.0,
                              enlargeCenterPage: false,
                              enableInfiniteScroll: false,
                              initialPage: 2,
                            ),
                            items: returnList(context),
                          ),),
                        ],
                      ),
                    ) : Container(
                      color: Colors.black.withOpacity(0.65),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/geri.png', color: Colors.amberAccent),
                                    onPressed: () {setState(() {isClicked=false;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Geri"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          ),
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/asama.png', color: Colors.amberAccent,),
                                    onPressed: () {setState(() {isDisplaySticker = true;index=0;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Aşamalar"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          ),
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/ay.png', color: Colors.amberAccent,),
                                    onPressed: () {setState(() {isDisplaySticker = true;index=1;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Aylar"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          ),
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/hafta.png', color: Colors.amberAccent),
                                    onPressed: () {setState(() {isDisplaySticker = true;index=2;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Haftalar"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          ),
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/bebek.png', color: Colors.amberAccent),
                                    onPressed: () {setState(() {isDisplaySticker = true;index=3;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Bebek"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          ),
                          Expanded(flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: Image.asset('images/cesit.png', color: Colors.amberAccent),
                                    onPressed: () {setState(() {isDisplaySticker = true;index=4;});}
                                ),
                                Text(AppLocalizations.of(context).translate("Çeşitli"),style: TextStyle(color: Colors.amberAccent))
                              ],
                            ),
                          )
                        ],
                      ),
                    ) : Container(
                      color: Colors.black.withOpacity(0.65),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(Icons.filter, color: Colors.amberAccent),
                                onPressed: (){setState(() {isClicked = true; isDisplayFilters = true;});},
                              ),
                              Text(AppLocalizations.of(context).translate("Filtreler"),style: TextStyle(color: Colors.amberAccent))
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(TablerIcons.sticker, color: Colors.amberAccent),
                                onPressed: () async {setState(() {isClicked = true;});},
                              ),
                              Text(AppLocalizations.of(context).translate("Çıkartmalar"),style: TextStyle(color: Colors.amberAccent))
                            ],
                          )
                        ],
                      ),
                    )
                )
              ]
          ),
        ),
    );
  }
}

Future<String> _getListString() async {
  final prefs = await SharedPreferences.getInstance();
  final listString = prefs.getString('listString') ?? null;
  return listString;
}

void popUpTrash(BuildContext context){
  Widget continueButton = TextButton(
    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed))
            return Colors.transparent;
          return null; // Defer to the widget's default.
        })),
    child: Text(AppLocalizations.of(context).translate("Tamam"), style: TextStyle(color: Colors.black,),),
    onPressed: (){Navigator.pop(context);},
  );
  showCupertinoDialog(
      barrierDismissible: false,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          content: Column(
            children: [
              Text(AppLocalizations.of(context).translate("Eklediğiniz çıkartmayı silmek için çıkartmanın üzerine çift tıklayın.")),
            ],
          ),
          actions: [continueButton],
        );
      }, context: context);
}

void popUpPalette(BuildContext context){
  Widget continueButton = TextButton(
    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed))
            return Colors.transparent;
          return null; // Defer to the widget's default.
        })),
    child: Text(AppLocalizations.of(context).translate("Tamam"), style: TextStyle(color: Colors.black,),),
    onPressed: (){Navigator.pop(context);},
  );
  showCupertinoDialog(
      barrierDismissible: false,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          content: Column(
            children: [
              Text(AppLocalizations.of(context).translate("Eklediğiniz çıkartmanın rengini değiştirmek için çıkartmanın üzerine parmağınızı basılı tutun.")),
            ],
          ),
          actions: [continueButton],
        );
      }, context: context);
}

void popUpTrue(BuildContext context){
  Widget continueButton = TextButton(
    child: Text(AppLocalizations.of(context).translate("Tamam"), style: TextStyle(color: Colors.black,),),
    onPressed: (){Navigator.pop(context);},
  );
  showCupertinoDialog(
      barrierDismissible: false,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          content: Column(
            children: [
              Text(AppLocalizations.of(context).translate("Resim kaydedildi.")),
              Container(
                  height:(60 / 812) * MediaQuery.of(context).size.height,
                  width: (45 / 375) * MediaQuery.of(context).size.width,
                  child: FittedBox(child: Icon(Icons.file_download_done_rounded, color: Colors.black,))),
            ],
          ),
          actions: [continueButton],
        );
      }, context: context );
}

void popUpFalse(BuildContext context){
  Widget continueButton = TextButton(
    child: Text(AppLocalizations.of(context).translate("Tamam"), style: TextStyle(color: Colors.black,),),
    onPressed: (){Navigator.pop(context);},
  );
  showCupertinoDialog(
      barrierDismissible: false,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
          content: Column(
            children: [
              Text(AppLocalizations.of(context).translate("Resim kaydedilemedi. Happy Photos'un resim kaydedebilmesi için galeriye erişmesine izin verin.")),
            ],
          ),
          actions: [continueButton],
        );
      }, context: context );
}

void popUpReminder(BuildContext context){
  Widget continueButton = TextButton(
    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed))
            return Colors.transparent;
          return null; // Defer to the widget's default.
        })),
    child: Text(AppLocalizations.of(context).translate("Tamam"), style: TextStyle(color: Colors.black,),),
    onPressed: (){Navigator.pop(context);},
  );
  Widget doNotShowAgainButton = TextButton(
    style: ButtonStyle(overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed))
            return Colors.transparent;
          return null; // Defer to the widget's default.
        })),
    child: Text(AppLocalizations.of(context).translate("Tekrar Gösterme"), style: TextStyle(color: Colors.black,),),
    onPressed: (){
      _setReminder();
      Navigator.pop(context);
      },
  );
  showCupertinoDialog(
      barrierDismissible: false,
      builder: (BuildContext context){
        return CupertinoAlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: (40 / 812.0) * MediaQuery.of(context).size.height,
                      width: (40 / 375) * MediaQuery.of(context).size.height,
                      child: Image.asset('images/cop.png', fit: BoxFit.scaleDown,)
                    ),
                    Container(
                      height: (40 / 812.0) * MediaQuery.of(context).size.height,
                      width: (40 / 375) * MediaQuery.of(context).size.height,
                      child: Image.asset('images/palet.png',fit: BoxFit.scaleDown,)
                    )
                  ],
                ),
                Container(height: 5, width: 5),
                Text(AppLocalizations.of(context).translate("Eklediğiniz çıkartmayı silmek için üzerine çift tıklayın. Rengini değiştirmek için ise parmağınızı üzerine basılı tutun."))
              ],
            ),
          actions: [continueButton, doNotShowAgainButton],
        );
      }, context: context );
}

Future<bool> _getReminder() async {
  final prefs = await SharedPreferences.getInstance();
  final reminder = prefs.getBool('reminder') ?? false;
  return reminder;
}

Future<void> _setReminder() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('reminder', true);
}

Future<void> checkerFunction(BuildContext context) async {
  bool flag = await _getReminder();
  if(flag) return;
  else popUpReminder(context);
}
