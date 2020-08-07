import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:firebase_messaging/firebase_messaging.dart';



class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  Future<void> _launched;


  @override
  OfflineBuilder _check() { //check if it is offline or online
    return OfflineBuilder(
        connectivityBuilder: (
            BuildContext context,
            ConnectivityResult connectivity,
            Widget child,
            ) {
          final bool connected = connectivity != ConnectivityResult.none;
          return new Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                height: 24.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  color: connected ? Color(0xFF00EE44) : Color(0xFFEE4400),
                  child: Center(
                    child: Text("${connected ? 'ONLINE' : 'OFFLINE'}"),
                  ),
                ),
              ),
              Center(
                child: new Text(
                  'Yay!',
                ),
              ),
            ],
          );
        },
    );
  }






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

      resizeToAvoidBottomInset: true, //bu kolayca kaymasını saglıyo  //keyboard açılınca yeri sabit kalıyor
      body: SafeArea(
          child: WillPopScope(
            onWillPop: _onBackPressed,
            child: WebView (

              onWebResourceError: (WebResourceError ) {

                print("No Connection solve it");
              },
                initialUrl: "https://www.pusulahaber.com.tr",
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController); // WebViewController instance can be obtained by setting the WebView.onWebViewCreated callback for a WebView widget.
                },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) async{
                if (request.url.startsWith('https://www.pusulahaber.com.tr')) {
                  print('allowing navigation to $request}');
                  return NavigationDecision.navigate;
                }
                print('no restriction to go this page $request');
                if (await canLaunch(request.url)) {
                  await launch(
                    request.url,
                    forceSafariVC: true,
                    forceWebView: false,
                    headers: <String, String>{'header_key': 'header_value'},
                  );
                } else {
                  throw 'Could not launch $request.url';
                }
                return NavigationDecision.prevent;
              },
              onPageFinished: (String url) {
                print('Page finished loading: $url');
              },

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

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }


}