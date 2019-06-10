import 'package:flutter/material.dart';

import 'LocationType.dart';
import 'POIService.dart';
import 'Page.dart';

class Places {
  final VoidCallback stateChanged;

  LocationType currentLocation;

  Places(
      {Key key, @required this.currentLocation, @required this.stateChanged});

  List<Page> places = [];

  static double initialRadius = 100;

  double radius = initialRadius;

  Future refresh([LocationType curLoc]) async {
    if (curLoc != null) {
      this.currentLocation = curLoc;
    }
    var poi = POIService();
    for (double r = radius; r < 10000; r *= 2) {
      setState(() {
        radius = r;
      });
      var places = await poi.queryWikipedia(
          currentLocation.latitude, currentLocation.longitude, r);
      print('wiki places: ' + places.length.toString());
      // search for bigger and bigger radius until something is visible
      if (places.length > 0) {
        setState(() {
          this.places = places;
        });
        break; // some POI found, stop increasing radius
      }
    }
    //print(places);
    setState(() {
      this.places = places;
    });
  }

  setState(VoidCallback callback) {
    callback();
    stateChanged();
  }
}
