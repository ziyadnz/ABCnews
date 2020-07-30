import 'package:flutter/material.dart';
import 'MyHomePage.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUSULA',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blue[400], //arkasının rengini ayarlıyor,

      ),
      home: MyHomePage(title: 'App'),
    );
  }
}

