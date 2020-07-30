import 'package:abcnews/model/message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';


/*mapping into the message.dart
with on State&Launch&Resume steps u can choose push message options
*/
class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging =FirebaseMessaging();  //plugin den
  final List<Message> messages=[];

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic>message) async {  //execute this when app is open
        print("onMessage: $message");
        final notification=message  ['notification'];
        setState(() {
          messages.add(Message(
            title: notification['title'], body:notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic>message) async {       //iff app is closed
       print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic>message) async {       //click notification continue with this //**WHEN APP IS OPEN***
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(                      //_firebase for ios notification
      const IosNotificationSettings(sound: true,badge: true,alert: true));

  }


  @override
  Widget build(BuildContext context) => ListView(
    children: messages.map(buildMessage).toList(),
  );

  Widget buildMessage(Message message) =>ListTile(
    title: Text(message.title),
    subtitle: Text(message.body),
  );


}
