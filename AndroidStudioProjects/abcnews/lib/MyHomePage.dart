import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Uygulamadan Çık'),
            content: Text('Bu uygulamadan çıkmak istediğinize emin misiniz?'),
            actions: <Widget>[
              FlatButton(
                child: Text('HAYIR'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('EVET'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: _onBackPressed,

        child: Container(

          color: Colors.black,
          child: SafeArea(
            child: WebView(
              initialUrl: "https://www.pusulahaber.com.tr",
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController); // WebViewController instance can be obtained by setting the WebView.onWebViewCreated callback for a WebView widget.


              },
            ),
          ),
        ),
      ),
      floatingActionButton: FutureBuilder<WebViewController>(   //burası geri tusu
          future: _controller.future,
          builder: (BuildContext context,
              AsyncSnapshot<WebViewController> controller) {
            if (controller.hasData) {
              return FloatingActionButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () {
                    controller.data.goBack();
                  });
            }

            return Container();
          }
      ),
    );
  }
}