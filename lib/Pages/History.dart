import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:happy_photos/services/photos.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'imageChange.dart';

class History extends StatefulWidget {
  const History({Key key}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {

  List<Photos> list = [];

  Future<String> _getListString() async {
    final prefs = await SharedPreferences.getInstance();
    final listString = prefs.getString('listString') ?? null;
    return listString;
  }

   Future<void> _setList() async {
    String listString = await _getListString();
    list = Photos.decodeItems(listString);
  }

  @override
  void initState() {
    super.initState();
    _setList().then((value){setState(() {});});
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
          Container(
            child: GridView.builder(
                itemCount: list.length,
                padding: EdgeInsets.all(2.5),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 2.5,
                    mainAxisSpacing: 2.5),
                itemBuilder: (BuildContext context, int index){
                  return GestureDetector(
                    onTap: () async{
                      final time = DateTime.now().toIso8601String();
                      print(time);
                      final tempDir = await getTemporaryDirectory();
                      final file = await new File('${tempDir.path}/screenshot_$time.jpg').create();
                      file.writeAsBytesSync(list[index].bytes);
                      Future.delayed(Duration(milliseconds: 0)).then(
                            (value) => Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => EditPhotoScreen(image: file),
                          ),
                        ),
                      );
                    },
                    child: GridTile(
                        child: Image.memory(list[index].bytes, fit: BoxFit.fill),
                    ),
                  );
                })
          ),
        ],
      )
    );
  }
}
