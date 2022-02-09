import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:happy_photos/services/app_localizations.dart';

class HistoryDefault extends StatefulWidget {
  const HistoryDefault({Key key}) : super(key: key);

  @override
  _HistoryDefaultState createState() => _HistoryDefaultState();
}

class _HistoryDefaultState extends State<HistoryDefault> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(AppLocalizations.of(context).translate("Geçmiş")),
        backgroundColor: Colors.black.withOpacity(0.65),
        leading: IconButton(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          onPressed: (){Navigator.pushReplacementNamed(context, '/home');},
        ),
      ),
      body: Stack(
        children: [
          Container(color: Colors.black),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(flex: 3),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Expanded(
                            flex: 14,
                            child: Text(
                              AppLocalizations.of(context).translate("Fotoğraf kaydetmek için düzenleme ekranında"),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 14,
                            child: ImageIcon(
                              AssetImage('images/save.png'),
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(),
                          ),
                          Expanded(
                            flex: 14,
                            child: Text(
                              AppLocalizations.of(context).translate("simgesini kullanın."),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
              ),
              Spacer(flex: 3)
            ],
          )
        ],
      ),
    );
  }
}
