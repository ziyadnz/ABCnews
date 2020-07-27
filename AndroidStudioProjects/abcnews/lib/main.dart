import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


void main() => runApp(MaterialApp(
  title: 'Flutter Browser',
  theme: ThemeData(
    primarySwatch: Colors.deepOrange,
  ),
  home: MyHomePage(),
));

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  WebViewController _webViewController;
  TextEditingController _teController = new TextEditingController();
  bool showLoading = false;



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,      //bunla klawye acılma ayarı
      body: Container(
        color: Colors.black,    //unsafe area color
        child: SafeArea(

          child: Container(
            
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,   // ekrana yerleştiriyo width: MediaQuery.of(context).size.width*0.5 yaparsan arısından yapar
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Flexible(
                    child: Stack(
                      children: <Widget>[
                        WebView(
                          initialUrl: 'https://abcgazetesi.com/',
                          javascriptMode: JavascriptMode.unrestricted,

                          onPageFinished: (data){

                          },

                          onWebViewCreated: (webViewController){
                            _webViewController = webViewController;
                          },
                        ),
                        (showLoading)?Center(child: CircularProgressIndicator(),):Center()  //bununla yuklendikten sonra olusturulur
                      ],
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}