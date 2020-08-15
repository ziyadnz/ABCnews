import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:device_info/device_info.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

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

  bool internet;
  Future<ConnectivityResult> _checkInternetConnectivity() async {
    var result = await Connectivity().checkConnectivity();

    if (result == ConnectivityResult.none) {
      internet = false; //No connection
      print('internet in future $internet');
      return result;
    } else if (result == ConnectivityResult.mobile) {
      internet = true;
      print('internet in future $internet');
      return result;
    } else if (result == ConnectivityResult.wifi) {
      internet = true;
      print('internet in future $internet');
      return result;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceinfo();
    _checkInternetConnectivity()
   
  }

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
    _checkInternetConnectivity();
    if (internet == true) {
      print('in if $internet');
      return Scaffold(
        resizeToAvoidBottomInset: true,
        //bu kolayca kaymasını saglıyo  //keyboard açılınca yeri sabit kalıyor
        body: SafeArea(
          child: WillPopScope(
            onWillPop: _onBackPressed,
            child: WebView(
              onWebResourceError: (WebResourceError webviewer) {
                print("No Connection solve it");
              },
              initialUrl: "https://www.pusulahaber.com.tr",
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                /* WebViewController instance can be obtained by setting the WebView.onWebViewCreated callback for a WebView widget. */
                _controller.complete(webViewController);
              },
              javascriptChannels: <JavascriptChannel>[
                _toasterJavascriptChannel(context),
              ].toSet(),
              navigationDelegate: (NavigationRequest request) async {
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

        /*    burası geri tusu    */
        floatingActionButton: FutureBuilder<WebViewController>(
            future: _controller.future,
            builder: (BuildContext context,
                AsyncSnapshot<WebViewController> controller) {
              if (controller.hasData) {
                return FloatingActionButton(
                  child: Icon(Icons.arrow_back),
                  onPressed: () {
                    controller.data.goBack();
                  },
                );
              }

              return Container();
            }),
      );
    } else //if no internet connection show this page
      return Scaffold(
        backgroundColor: Colors.blue,
        body: Center(
          child: Text('Hello World'),
        ),
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
