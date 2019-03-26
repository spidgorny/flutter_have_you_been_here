import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_have_you_been_here/NotifyService.dart';
import 'package:flutter_have_you_been_here/POIService.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';

import 'LocationInfoPage.dart';
import 'LocationType.dart';
import 'Page.dart';

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

  String title;

  static double initialRadius = 100;
  double radius = initialRadius;

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

      var poi = POIService();
      for (double r = radius; r < 10000; r *= 2) {
        setState(() {
          radius = r;
        });
        var places = await poi.queryWikipedia(tmp.latitude, tmp.longitude, r);
        print(places.length);
        // search for bigger and bigger radius until something is visible
        if (places.length > 0) {
          setState(() {
            this.places = places;
          });
          break;
        }
      }
      //print(places);
      setState(() {
        this.places = places;
      });
    } on Exception {
      currentLocation = null;
    }
  }

  String _status = '';
  List<DateTime> _events = [];

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
              LiquidPullToRefresh(
        onRefresh: () {
          print('refresh');
          return this.refresh();
        },
        child: places.length > 0
            ? ListView(shrinkWrap: true, children: getPlaceTiles())
            : ListView(shrinkWrap: true, children: [
                ListTile(
                    title: Text(
                        'Nothing interesing within ${(radius / 1000).toStringAsFixed(3)} km nearby ¯\\_(ツ)_/¯.'
                        'Pull down to refresh'))
              ]),
      )
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
    withDivs.add(ListTile(
      title: Text('Load more...'),
      onTap: () {
        radius *= 2;
        refresh();
      },
    ));
    return withDivs;
  }
}
