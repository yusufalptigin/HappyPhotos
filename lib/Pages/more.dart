import 'package:flutter/material.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'dart:core';

class More extends StatefulWidget {
  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {

  void popUp (String url) {
    Widget continueButton = TextButton(
      child: Text(
        AppLocalizations.of(context).translate("Evet"), style: TextStyle(color: Colors.black) ),
      onPressed: () async {if (await canLaunch(url)) await launch(url);Navigator.pop(context);},
    );
    Widget cancelButton = TextButton(
      child: Text(
          AppLocalizations.of(context).translate("Hayır"), style: TextStyle(color: Colors.black)),
      onPressed: () {Navigator.pop(context);},
    );
    showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => CupertinoAlertDialog(
          title: Text(AppLocalizations.of(context).translate("Happy Photos uygulamasından çıkılacak")),
          content: Text(AppLocalizations.of(context).translate("Devam Edilsin mi?")),
          actions: [
            cancelButton,
            continueButton,
          ],
        )
    );
  }

  void rate () async {
    if (Platform.isAndroid) {
      const url = 'https://play.google.com/store/apps/details?id=tr.com.happydigital.happyphotos&hl=en_US&gl=US';
      popUp(url);
    } else if (Platform.isIOS) {
      const url = 'https://apps.apple.com/tr/app/happy-photos/id1317783824?l=tr';
      popUp(url);
    }
  }

  void mom () async {
    if (Platform.isAndroid) {
      const url = 'https://play.google.com/store/apps/details?id=tr.com.happydigital.happymom&hl=tr';
      popUp(url);
    } else if (Platform.isIOS) {
      const url = 'https://apps.apple.com/tr/app/mutlu-anne-hamilelik-takibi/id1141379201';
      popUp(url);
    }
  }

  void kid () async {
    if (Platform.isAndroid) {
      const url = 'https://play.google.com/store/apps/details?id=tr.com.happydigital.happykids&hl=tr';
      popUp(url);
    } else if (Platform.isIOS) {
      const url = 'https://apps.apple.com/tr/app/happy-kids-bebek-geli%C5%9Fimi/id1349245161?l=tr';
      popUp(url);
    }
  }

  void step () async {
    if (Platform.isAndroid) {
      const url = 'https://play.google.com/store/apps/details?id=tr.com.happydigital.pedometer&hl=tr&gl=US';
      popUp(url);
    } else if (Platform.isIOS) {
      const url = 'https://apps.apple.com/tr/app/ad%C4%B1m-sayar/id736071203?l=tr';
      popUp(url);
    }
  }

  void peride () async {
    if (Platform.isAndroid) {
      const url = 'https://play.google.com/store/apps/details?id=tr.com.happydigital.peride&hl=tr&gl=US';
      popUp(url);
    } else if (Platform.isIOS) {
      const url = 'https://apps.apple.com/tr/app/periyot-g%C3%BCnl%C3%BC%C4%9F%C3%BC-peride/id577097723?l=tr';
      popUp(url);
    }
  }

  void mail () {
    final Uri _emailLaunchUri = Uri(
        scheme: 'mailto',
        path: 'happy@happydigital.com.tr',
        queryParameters: {
          'subject': 'HappyPhotos-Öneri/Suggestion'
        }
    );
    popUp(_emailLaunchUri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate("Daha Fazla")),
        backgroundColor: Colors.black.withOpacity(0.65),
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: (){Navigator.pushReplacementNamed(context, '/home');},
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: rate,
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding:EdgeInsets.fromLTRB(15,0,0,0),child: Text(
                      AppLocalizations.of(context).translate("Bizi Değerlendir"),
                      style: TextStyle(color: Colors.black),)),
                    Padding(padding:EdgeInsets.fromLTRB(0,0,10,0),child: Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95)))
                  ],
                ),
              ),
            ),
          ),
          Divider(height: MediaQuery.of(context).size.height * 0.001, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.65),),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: mail,
              child: Container(
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(padding:EdgeInsets.fromLTRB(15,0,0,0),child: Text(
                      AppLocalizations.of(context).translate("Öneride Bulun"),
                      style: TextStyle(color: Colors.black),)),
                    Padding(padding:EdgeInsets.fromLTRB(0,0,10,0),child: Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95)))
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(padding:EdgeInsets.fromLTRB(15,0,0,0),child: Text(
                    AppLocalizations.of(context).translate("Happy Appz"),
                    style: TextStyle(fontSize: 18,color: Colors.black),)),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: SingleChildScrollView(scrollDirection:Axis.vertical,child: Container(
              color: Colors.white,
              child: Column(children: [
                InkWell(
                  onTap: mom,
                  child: Row(
                    children: [
                      Expanded(flex:2,child: Container(child: Padding(padding: EdgeInsets.all(11),
                        child:ClipRRect(borderRadius: BorderRadius.circular(8),child: Image.asset('images/mom.png')),))),
                      Expanded(flex:7,child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                        Text(
                          AppLocalizations.of(context).translate("Happy Mom"),
                          style: TextStyle(color: Colors.black,fontSize: 15),),
                        Container(height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                            AppLocalizations.of(context).translate("Hamilelik Takip Uygulaması"),
                            style: TextStyle(color: Colors.grey.withOpacity(0.95),))],)),
                      Expanded(flex:1,child: Column(mainAxisAlignment:MainAxisAlignment.end,children: [
                        Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95))
                      ],))
                    ],
                  ),
                ),
                Divider(height: MediaQuery.of(context).size.height * 0.001, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.65),),
                InkWell(
                  onTap: kid,
                  child: Row(
                    children: [
                      Expanded(flex:2,child: Container(child: Padding(padding: EdgeInsets.all(11),
                        child: ClipRRect(borderRadius: BorderRadius.circular(8),child: Image.asset('images/kids.jpeg')),))),
                      Expanded(flex:7,child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                        Text(
                          AppLocalizations.of(context).translate("Happy Kids"),
                          style: TextStyle(color: Colors.black,fontSize: 15),),
                        Container(height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                          AppLocalizations.of(context).translate("0-4 Yaş Çocuk Gelişim Takip Uygulaması"),
                          style: TextStyle(color: Colors.grey.withOpacity(0.95),),)],),),
                      Expanded(flex:1,child: Column(mainAxisAlignment:MainAxisAlignment.end,children: [
                        Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95))
                      ],))
                    ],
                  ),
                ),
                Divider(height: MediaQuery.of(context).size.height * 0.001, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.65),),
                InkWell(
                  onTap: step,
                  child: Row(
                    children: [
                      Expanded(flex:2,child: Container(child: Padding(padding: EdgeInsets.all(11),child:
                      ClipRRect(borderRadius: BorderRadius.circular(8),
                          child: Image.asset('images/step.png')),))),
                      Expanded(flex:7,child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                        Text(
                          AppLocalizations.of(context).translate("Adım Sayar"),
                          style: TextStyle(color: Colors.black,fontSize: 15),),
                        Container(height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                            AppLocalizations.of(context).translate("Adım Sayar ve Su Hatırlatıcı"),
                            style: TextStyle(color: Colors.grey.withOpacity(0.95),))],)),
                      Expanded(flex:1,child: Column(mainAxisAlignment:MainAxisAlignment.end,children: [
                        Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95))
                      ],))
                    ],
                  ),
                ),
                Divider(height: MediaQuery.of(context).size.height * 0.001, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.65),),
                InkWell(
                  onTap: peride,
                  child: Row(
                    children: [
                      Expanded(flex:2,child: Container(child: Padding(padding: EdgeInsets.all(11),child:
                      ClipRRect(borderRadius: BorderRadius.circular(8),child: Image.asset('images/peride.png')),))),
                      Expanded(flex:7,child: Column(crossAxisAlignment:CrossAxisAlignment.start,children: [
                        Text(
                          AppLocalizations.of(context).translate("Peride"),
                          style: TextStyle(color: Colors.black,fontSize: 15),),
                        Container(height: MediaQuery.of(context).size.height * 0.01),
                        Text(
                            AppLocalizations.of(context).translate("Regl/Adet Takvimi"),
                            style: TextStyle(color: Colors.grey.withOpacity(0.95),)),],)),
                      Expanded(flex:1,child: Column(mainAxisAlignment:MainAxisAlignment.end,children: [
                        Icon(Icons.arrow_forward_ios,color: Colors.grey.withOpacity(0.95))
                      ],))
                    ],
                  ),
                ),
                Divider(height: MediaQuery.of(context).size.height * 0.001, indent: 15, endIndent: 15, color: Colors.grey.withOpacity(0.65),),
              ],),
            )),
          )
        ],
      ),
    );
  }
}
