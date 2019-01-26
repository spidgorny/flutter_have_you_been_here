import 'package:flutter/material.dart';
import 'package:flutter_have_you_been_here/Page.dart';

class LocationInfoPage extends StatelessWidget {
  final Page model;

  const LocationInfoPage({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(model.title), actions: []),
        body: Container());
  }
}
