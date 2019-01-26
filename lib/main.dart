import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_have_you_been_here/LocationInfoPage.dart';
import 'package:flutter_have_you_been_here/LocationType.dart';
import 'package:flutter_have_you_been_here/Page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POI nearby',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'POI nearby'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationType currentLocation;

  String error;

  List<Page> places = [];

  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  void initAsyncState() async {
    var location = new Location();

    try {
      var locationData = await location.getLocation();
      print(locationData);
      LocationType tmp = LocationType.fromResult(locationData);
      print(tmp);
      setState(() {
        currentLocation = tmp;
      });
      var places = await queryWikipedia(
          currentLocation.latitude, currentLocation.longitude);
      //print(places);
      setState(() {
        this.places = places;
      });
    } on Exception {
      currentLocation = null;
    }
  }

  Future<List<Page>> queryWikipedia(double lat, double lon,
      [double radius = 1000]) async {
    var url = 'https://en.wikipedia.org/w/api.php?action=query' +
        '&prop=coordinates%7Cpageimages%7Cpageterms%7Cinfo%7Cextracts' +
        '&exintro=1' +
        // '&srprop=titlesnippet'+
        '&colimit=50&piprop=thumbnail&pithumbsize=708&pilimit=50' +
        '&wbptterms=description' +
        '&inprop=url' +
        '&iwurl=1' +
        '&list=alllinks' +
        '&generator=geosearch' +
        '&ggscoord=${lat.toString()}%7C' +
        lon.toString() +
        '&ggsradius=' +
        radius.toString() +
        '&ggslimit=50&format=json&origin=*';
    print(url);
    var res = await http.get(url);
    if (res.statusCode == 200) {
      var json = jsonDecode(res.body);
      for (var p in Map<String, dynamic>.from(json['query']['pages']).values) {
        var page = Page.fromJson(p);
        print(page);
        places.add(page);
      }
      print(places.first);
      return places;
    } else {
      setState(() {
        this.error = res.reasonPhrase;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: [
        Text(
          currentLocation.toString(),
        )
      ]),
      body: SingleChildScrollView(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          error != null
              ? Row(
                  children: <Widget>[Text(error)],
                )
              : Container(),
          places.length > 0
              ? Column(children: getPlaceTiles())
              : Center(child: Text('Nothing interesing nearby ¯\\_(ツ)_/¯')),
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          notifyTest();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  List<Widget> getPlaceTiles() {
    var tiles = places.map((Page p) {
      var distance = p.distanceTo(currentLocation);
      return ListTile(
        title: Text(p.title),
        leading: p.image != null
            ? Image.network(
                p.image,
                width: 64,
              )
            : null,
        trailing: distance != null
            ? Chip(
                label: Text(distance.toStringAsFixed(2) + ' m'),
              )
            : null,
        onTap: () async {
          print(p.toJson());
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LocationInfoPage(
                      model: p,
                      currentLocation: currentLocation,
                    )),
          );
        },
      );
    }).toList();

    List<Widget> withDivs = [];
    for (var tile in tiles) {
      withDivs.add(tile);
      withDivs.add(Divider());
    }
    return withDivs;
  }

  void notifyTest() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        selectNotification: (string) {
      print('onSelect');
    });

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'Channel1', 'Channel for Notifications', 'To notify about POI nearby',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item id 2');
  }
}
