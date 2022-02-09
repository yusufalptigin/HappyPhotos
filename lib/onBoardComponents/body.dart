import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:happy_photos/services/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {

  Future<bool> _getVisibilityOnBoard() async {
    final prefs = await SharedPreferences.getInstance();
    final visibilityOnBoard = prefs.getBool('visibilityOnBoard') ?? false;
    return visibilityOnBoard;
  }

  Future<void> _setVisibilityOnBoard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visibilityOnBoard', true);
  }

  Future<void> _setInitScreen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('initScreen', 1);
  }

  int current = 0;

  @override
  Widget build(BuildContext context) {
    List<Map<String, Widget>> data = [
      {
        "title": Text(
          AppLocalizations.of(context).translate("Uygulamaya geçiş yapmak için kaydırın."),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.pinkAccent,
          ),
        ),
        "text": Text(
          AppLocalizations.of(context).translate("Happy Photos"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (26 / 375.0) * MediaQuery.of(context).size.width,
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        "image": Image.asset(
              "images/image.png",
              height: (325 / 812.0) * MediaQuery.of(context).size.height,
              width: (325 / 375.0) * MediaQuery.of(context).size.width,
            ),
        "textTitle": Text(
          AppLocalizations.of(context).translate("Happy Photos'a Hoş Geldiniz"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        )
      },
      {
        "title": RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                style: TextStyle(color: Colors.pinkAccent),
                text: AppLocalizations.of(context).translate("Fotoğraflarınızı bizimle paylaşmak için "),
              ),
              TextSpan(
                style: TextStyle(color: Colors.pink[800]),
                text: AppLocalizations.of(context).translate("@happymomapp"),
                recognizer: TapGestureRecognizer()..onTap =  () async {
                  var url = "https://www.instagram.com/happymomapp/";
                  if (await canLaunch(url)) await launch(url);
                  else throw 'Link açılamadı.';
                }
               ),
              TextSpan(
                style: TextStyle(color: Colors.pinkAccent),
                text: AppLocalizations.of(context).translate(" ve "),
              ),
              TextSpan(
                style: TextStyle(color: Colors.pink[800]),
                text: AppLocalizations.of(context).translate("@happyphotosapp"),
                  recognizer: TapGestureRecognizer()..onTap =  () async {
                    var url = "https://www.instagram.com/happyphotosapp/";
                    if (await canLaunch(url)) await launch(url);
                    else throw 'Could not launch $url';
                  }
              ),
              TextSpan(
                style: TextStyle(color: Colors.pinkAccent),
                text: AppLocalizations.of(context).translate(" instagram adreslerine mesaj atabilirsiniz."),
              ),
            ]
          ),
        ),
        "text": Text(
          AppLocalizations.of(context).translate("Instagram"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (26 / 375.0) * MediaQuery.of(context).size.width,
            color: Colors.pink,
            fontWeight: FontWeight.bold,
          ),
        ),
        "image": Image.asset(
          "images/insta.png",
          height: (325 / 812.0) * MediaQuery.of(context).size.height,
          width: (325 / 375.0) * MediaQuery.of(context).size.width,
        ),
        "textTitle": Text(
          AppLocalizations.of(context).translate("Fotoğraflarınızı Bizimle Paylaşın"),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.pink,
          ),
        )
      },
    ];
    return SafeArea(
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            Expanded(
              flex: 10,
              child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      current = value;
                      if (value == 1) {
                        _setVisibilityOnBoard();
                      }
                    });
                  },
                  itemCount: data.length,
                  itemBuilder: (context, index) => onBoardContents(
                    text: data[index]["text"],
                    image: data[index]["image"],
                    title: data[index]["title"],
                    textTitle: data[index]["textTitle"],
                  )),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (20 / 812.0) * MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            data.length, (index) => animation(index: index))),
                    Spacer(),
                    FutureBuilder(
                      future: _getVisibilityOnBoard(),
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return SizedBox(
                            width: double.infinity,
                            height: (56 / 812.0) * MediaQuery.of(context).size.height,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.pink,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context).translate("Happy Photos'a Devam Edin"),
                                style: TextStyle(
                                  fontSize: (18 / 375.0) * MediaQuery.of(context).size.width,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                _setInitScreen();
                                Navigator.pushReplacementNamed(context, '/home');
                              },
                            ),
                          );
                        } else
                          return Container();
                      },
                    ),
                    Spacer()
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  AnimatedContainer animation({int index}) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      margin: EdgeInsets.only(right: 8),
      height: MediaQuery.of(context).size.height * 0.012,
      width: MediaQuery.of(context).size.width * 0.06,
      decoration: BoxDecoration(
        color: index == current ? Colors.pink[700] : Colors.pinkAccent,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class onBoardContents extends StatelessWidget {
  const onBoardContents(
      {Key key, this.text, this.image, this.title, this.textTitle})
      : super(key: key);
  final Widget text, image, title, textTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Spacer(
            flex: 1,
          ),
          text,
          Spacer(
            flex: 1,
          ),
          image,
          Spacer(
            flex: 1,
          ),
          textTitle,
          Spacer(
            flex: 1,
          ),
          title,
          Spacer(
            flex: 1,
          ),
        ],
      ),
    );
  }
}
