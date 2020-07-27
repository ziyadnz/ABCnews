import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(MaterialApp(
  title: 'NAME',

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

  void updateLoading(bool ls) {
    this.setState((){
      showLoading = ls;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[

              Flexible(

                  child: Stack(
                    children: <Widget>[
                      WebView(
                        initialUrl: 'https://abcgazetesi.com/',
                        onPageFinished: (data){
                          updateLoading(false);
                        },
                        javascriptMode: JavascriptMode.unrestricted,
                        onWebViewCreated: (webViewController){
                          _webViewController = webViewController;
                        },
                      ),
                      (showLoading)?Center(child: CircularProgressIndicator(),):Center()
                    ],
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }
}