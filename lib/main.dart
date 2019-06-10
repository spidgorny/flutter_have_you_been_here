import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_have_you_been_here/NotifyService.dart';
import 'package:flutter_have_you_been_here/POIService.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'LocationType.dart';
import 'Places.dart';
import 'PlacesListView.dart';

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask() async {
  print('[BackgroundFetch] Headless event received.');

  var location = new Location();

  var locationData = await location.getLocation();
  print(locationData);
  LocationType currentLocation = LocationType.fromResult(locationData);
  print(currentLocation);

  var poi = POIService();
  var places = await poi.queryWikipedia(
      currentLocation.latitude, currentLocation.longitude);
  print(places);
  if (places.length > 0) {
    var ns = NotifyService();
    ns.notifyTest();
  }

  BackgroundFetch.finish();
}

void main() {
  runApp(MyApp());
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<String>.value(value: 'foo'),
        ],
        child: MaterialApp(
          title: 'POI nearby',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  String title = 'POI nearby';

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  LocationType currentLocation;

  String error;

  String title;

  Places places;

  String _status = '';

  List<DateTime> _events = [];

  @override
  void initState() {
    super.initState();
    this.title = widget.title;
    initPackageInfo();
    refresh();
    initPlatformState();
  }

  initPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    //print(packageInfo);
    title += ' v' + packageInfo.version;
  }

  Future refresh() async {
    var location = new Location();

    try {
      var locationData = await location.getLocation();
      print(locationData);
      LocationType tmp = LocationType.fromResult(locationData);
      print(tmp);
      setState(() {
        currentLocation = tmp;
      });

      places = Places(
          currentLocation: currentLocation,
          stateChanged: () {
            print('main.dart setState calling');
            this.setState(() {
              print('main.dart setState called');
            });
          });
      places.refresh(currentLocation);
    } on Exception {
      currentLocation = null;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            enableHeadless: true), () async {
      // This is the fetch-event callback.
      print('[BackgroundFetch] Event received');
      setState(() {
        _events.insert(0, new DateTime.now());
      });
      // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish();
    }).then((int status) {
      print('[BackgroundFetch] SUCCESS: $status');
      setState(() {
        _status = status.toString();
      });
    }).catchError((e) {
      print('[BackgroundFetch] ERROR: $e');
      setState(() {
        _status = e.toString();
      });
    });

    // Optionally query the current BackgroundFetch status.
    int status = await BackgroundFetch.status;
    setState(() {
      _status = status.toString();
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    enableBG();
  }

  enableBG() {
    BackgroundFetch.start().then((int status) {
      print('[BackgroundFetch] start success: $status');
    }).catchError((e) {
      print('[BackgroundFetch] start FAILURE: $e');
    });
  }

  disableBG() {
    BackgroundFetch.stop().then((int status) {
      print('[BackgroundFetch] stop success: $status');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: [
        Padding(padding: const EdgeInsets.all(16.0), child: Text(this._status)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            currentLocation.toString(),
          ),
        )
      ]),
      body: Container(
        child:
//          child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
//              children: <Widget>[
//          error != null
//              ? Row(
//                  children: <Widget>[Text(error)],
//                )
//              : Container(),
            places != null
                ? PlacesListView(places: places)
                : ListTile(title: Text('Location not detected ¯\\_(ツ)_/¯.')),
//        ],
//      )
//          ])
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('+ pressed');
          //var ns = NotifyService();
          //ns.notifyTest();
          backgroundFetchHeadlessTask();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
