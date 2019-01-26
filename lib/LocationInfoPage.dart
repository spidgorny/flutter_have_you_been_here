import 'package:flutter/material.dart';
import 'package:flutter_have_you_been_here/LocationType.dart';
import 'package:flutter_have_you_been_here/Page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

class LocationInfoPage extends StatelessWidget {
  final Page model;
  final LocationType currentLocation;

  const LocationInfoPage(
      {Key key, @required this.model, @required this.currentLocation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var distance = model.distanceTo(currentLocation);
    return Scaffold(
        appBar: AppBar(title: Text(model.title), actions: []),
        body: SingleChildScrollView(
          child: Column(children: [
            model.image != null
                ? Image.network(
                    model.image,
                  )
                : Container(),
            distance != null
                ? Chip(
                    avatar: Icon(Icons.location_on),
                    label: Text(distance.toStringAsFixed(2) + ' m'),
                  )
                : Container(),
            FlutterMap(
              options: new MapOptions(
                center: new LatLng(51.5, -0.09),
                zoom: 13.0,
              ),
              layers: [
                new TileLayerOptions(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c']),
                new MarkerLayerOptions(
                  markers: [
                    new Marker(
                      width: 80.0,
                      height: 80.0,
                      point: new LatLng(51.5, -0.09),
                      builder: (ctx) => new Container(
                            child: new FlutterLogo(),
                          ),
                    ),
                  ],
                ),
              ],
            )
          ]),
        ));
  }
}
