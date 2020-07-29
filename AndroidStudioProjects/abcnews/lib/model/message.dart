import 'package:flutter/material.dart';

//at here you are deploying firebase messages

@immutable
class Message{
  final String title;
  final String body;

  const Message({
    @required this.title,
    @required this.body,
  });

}