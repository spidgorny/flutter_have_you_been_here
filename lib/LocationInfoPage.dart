import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:map_native/map_native.dart';
import 'package:url_launcher/url_launcher.dart';

import 'LocationType.dart';
import 'Page.dart';
//import 'package:flutter_map/flutter_map.dart';
//import 'package:latlong/latlong.dart';

class LocationInfoPage extends StatelessWidget {
  final Page model;
  final LocationType currentLocation;

  const LocationInfoPage(
      {Key key, @required this.model, @required this.currentLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('LocationInfoPage::build');
    print(currentLocation);
    var distance = model.distanceTo(currentLocation);
    print('distance: ' + distance.toString());

//    var map1 = FlutterMap(
//      options: new MapOptions(
//        center: new LatLng(51.5, -0.09),
//        zoom: 13.0,
//      ),
//      layers: [
//        new TileLayerOptions(
//            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//            subdomains: ['a', 'b', 'c']),
//        new MarkerLayerOptions(
//          markers: [
//            new Marker(
//              width: 80.0,
//              height: 80.0,
//              point: new LatLng(51.5, -0.09),
//              builder: (ctx) => new Container(
//                    child: new FlutterLogo(),
//                  ),
//            ),
//          ],
//        ),
//      ],
//    );

//    var map2 = new Flexible(
//        child: new FlutterMap(
//      options: new MapOptions(
//        center: new LatLng(51.5, -0.09),
//        zoom: 5.0,
//      ),
//      layers: [
//        new TileLayerOptions(
//            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//            subdomains: ['a', 'b', 'c']),
//      ],
//    ));

    double height = MediaQuery.of(context).size.height;

    Widget map3;
    if (model.latLong != null) {
      map3 = new SizedBox(
          height: height / 2,
          child:
              new MapView(initialLocation: model.latLong, inititialZoom: 16.0));
    } else {
      map3 = Container();
    }

    return Scaffold(
        appBar: AppBar(title: Text(model.title), actions: []),
        body: SingleChildScrollView(
          child: Column(children: [
            model.image != null
                ? Image.network(
                    model.image,
                  )
                : Container(),
//            Text(model.extract),
//            HtmlView(data: model.extract),
            Html(
              data: model.extract,
              padding: EdgeInsets.all(16),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              distance != null
                  ? Chip(
                      avatar: Icon(Icons.location_on),
                      label: Text(distance.toStringAsFixed(2) + ' m'),
                    )
                  : Container(),
              RaisedButton(
                child: Text('Open Wikipedia'),
                onPressed: () async {
                  if (await canLaunch(model.fullurl)) {
                    await launch(model.fullurl);
                  }
                },
              ),
            ]),
            map3,
          ]),
        ));
  }
}
