import 'package:abcnews/main.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/rendering.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controllerCompleter =
      Completer<WebViewController>();

  WebViewController _controller;

  Future<bool> _exitApp(BuildContext context) async {
    //try with
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return Future.value(false);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
        ),
      );
    }
    return Future.value(true);
  }

  @override
  void initState() {
    //tek sefer çalışır uygulama açıldığında
    // TODO: implement initState
    super.initState();
    getDeviceinfo();
    _checkInternetConnectivity();
  }

  bool internet = false;
  Future<ConnectivityResult> _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      setState(() {
        internet = false; //No connection
        print('internet in future $internet');
      });
    } else if (result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi) {
      setState(() {
        internet = true;
        print('internet in future $internet');
      });
    }
    return result;
  }

/* To take device infos */
  DeviceInfoPlugin deviceInfo =
      DeviceInfoPlugin(); // instantiate device info plugin
  AndroidDeviceInfo androidDeviceInfo;

  String board,
      /* brand,device,hardware,host,id,product,type,androidid, */
      manufacture,
      model;

  bool isphysicaldevice;

  void getDeviceinfo() async {
    androidDeviceInfo = await deviceInfo
        .androidInfo; // instantiate Android Device Infoformation
    setState(() {
      /* board = androidDeviceInfo.board;brand = androidDeviceInfo.brand;device = androidDeviceInfo.device;hardware = androidDeviceInfo.hardware;host = androidDeviceInfo.host;id = androidDeviceInfo.id; */
      manufacture = androidDeviceInfo.manufacturer;
      model = androidDeviceInfo.model;
      /* product = androidDeviceInfo.product;type = androidDeviceInfo.type;isphysicaldevice = androidDeviceInfo.isPhysicalDevice;androidid = androidDeviceInfo.androidId; */
    });
    print('Manufacture $manufacture');
    print('Model $model');
  }
  /* End of device info */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //bu kolayca kaymasını saglıyo  //keyboard açılınca yeri sabit kalıyor
      body: internet
          ? SafeArea(
              child: WillPopScope(
                onWillPop: () => _exitApp(context),
                child: WebView(
                  onWebResourceError: (WebResourceError webviewer) {
                    setState(() {
                      internet = false;
                    });
                    print("No Connection solve it");
                  },
                  initialUrl: "https://www.pusulahaber.com.tr",
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    /* WebViewController instance can be obtained by setting the WebView.onWebViewCreated callback for a WebView widget. */
                    _controllerCompleter.future
                        .then((value) => _controller = value);
                    _controllerCompleter.complete(webViewController);
                  },
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                  navigationDelegate: (NavigationRequest request) async {
                    if (request.url
                        .startsWith('https://www.pusulahaber.com.tr')) {
                      return NavigationDecision.navigate;
                    }
                    print('no restriction to go this page $request');
                    /* if launch with browser */
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
            )
          : RefreshIndicator(
              child: ListView(
                children: [
                  Center(
                    child: Text("İnternete Bağlanılamadı"),
                  ),
                ],
              ),
              // ignore: missing_return
              onRefresh: () {
                Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
              }, //it give us a blank page
            ),

      /*    burası  refresh tusu  */
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }),
    );
  }

  /* For firebase */
  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(message.message),
            ),
          );
        });
  }
}
