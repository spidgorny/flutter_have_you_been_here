import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';

import 'Places.dart';
import 'PlacesListView.dart';

void main() {
  runApp(MyApp());
//  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
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
  LocationData currentLocation;

  String error;

  String title;

  Places places;

  bool loading = true;

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
    print('refresh');
    var location = new Location();

    try {
      LocationData locationData = await location.getLocation();
      print('refresh locationData');
      print(locationData);
      setState(() {
        currentLocation = locationData;

        loading = false;
        places = Places(
            currentLocation: currentLocation,
            stateChanged: () {
              print('main.dart setState calling');
              this.setState(() {
                print('main.dart setState called');
              });
            });
        places.refresh(currentLocation);
      });
    } on Exception {
      setState(() {
        loading = false;
        places = null;
        currentLocation = null;
      });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Configure BackgroundFetch.
    print('initPlatformState');

    // backgroundFetch.init();

    // Optionally query the current BackgroundFetch status.
//    int status = await BackgroundFetch.status;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    //enableBG();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: false, actions: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            currentLocation.latitude.toStringAsFixed(2) +
                ', ' +
                currentLocation.longitude.toStringAsFixed(2),
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
            loading
                ? Center(child: CircularProgressIndicator())
                : places != null
                    ? PlacesListView(places: places)
                    : ListTile(
                        title: Text('Location not detected ¯\\_(ツ)_/¯.')),
//        ],
//      )
//          ])
      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: () {
//          print('+ pressed');
//          //var ns = NotifyService();
//          //ns.notifyTest();
//          backgroundFetchHeadlessTask();
//        },
//        tooltip: 'Increment',
//        child: Icon(Icons.add),
//      ),
    );
  }

  backgroundFetchEventAction() async {
    // This is the fetch-event callback.
    print('[BackgroundFetch] Event received');

    loading = true;
    this.refresh();

    // IMPORTANT:  You must signal completion of your fetch task or the OS can punish your app
    // for taking too long in the background.
    //BackgroundFetch.finish();
  }
}
