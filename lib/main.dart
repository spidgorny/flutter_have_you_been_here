import 'dart:convert';

import 'package:flutter/material.dart';
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

class LocationType {
  double latitude;
  double longitude;
  double altitude;
  double speed;
  double speed_accuracy;
  double accuracy;

  LocationType(this.latitude, this.longitude, [this.altitude]);

  LocationType.fromResult(Map<String, double> data)
      : this.latitude = data['latitude'],
        this.longitude = data['longitude'],
        this.altitude = data['altitude'],
        this.speed = data['speed'],
        this.speed_accuracy = data['speed_accuracy'],
        this.accuracy = data['accuracy'];

  String toString() {
    return 'Lat: $latitude, Lon: $longitude, Alt: $altitude';
  }
}

class Page {
  int pageid;
  int ns;
  String title;
  int index;
  List coordinates;
  Map thumbnail;
  Map terms;
  String contentmodel;
  String pagelanguage;
  String pagelanguagehtmlcode;
  String pagelanguagedir;
  String touched;
  int lastrevid;
  int length;
  String fullurl;
  String editurl;
  String extract;

  Page.fromJson(Map<String, dynamic> data)
      : this.pageid = data['pageid'],
        this.ns = data['ns'],
        this.title = data['title'],
        this.index = data['index'],
        this.coordinates = data['coordinates'],
        this.thumbnail = data['thumbnail'],
        this.terms = data['terms'],
        this.contentmodel = data['contentmodel'],
        this.pagelanguage = data['pagelanguage'],
        this.pagelanguagehtmlcode = data['pagelanguagehtmlcode'],
        this.pagelanguagedir = data['pagelanguagedir'],
        this.touched = data['touched'],
        this.lastrevid = data['lastrevid'],
        this.length = data['length'],
        this.fullurl = data['fullurl'],
        this.editurl = data['editurl'],
        this.extract = data['extract'];

  String toString() {
    return 'Page {$title}';
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
    } on Exception {
      currentLocation = null;
    }
  }

  Future<String> queryWikipedia(double lat, double lon,
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
      return res.body;
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
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              currentLocation.toString(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          notifyTest();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
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
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.High);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, 'plain title', 'plain body', platformChannelSpecifics,
        payload: 'item id 2');
  }
}
