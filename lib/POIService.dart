import 'dart:convert';

import 'package:flutter_have_you_been_here/Page.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

class POIService {
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
      List<Page> places = [];
      if (json.containsKey('query') && json['query'].containsKey('pages')) {
        var pages = Map<String, dynamic>.from(json['query']['pages']);
        for (var p in pages.values) {
          var page = Page.fromJson(p);
//          print(page);
          places.add(page);
        }
//        print(places.first);
        LocationData userLocation =
            LocationData.fromMap({'latitude': lat, 'longitude': lon});
        places.sort((p1, p2) {
          return p1.distanceTo(userLocation) < p2.distanceTo(userLocation)
              ? -1
              : 1;
        });
      }
      return places;
    } else {
      print(res.reasonPhrase);
      return null;
    }
  }
}
