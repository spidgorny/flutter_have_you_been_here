import 'package:flutter_have_you_been_here/LocationType.dart';
import 'package:haversine/haversine.dart';

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

  double distanceTo(LocationType base) {
    if (coordinates.length > 0) {
      var pos = coordinates[0];
      final harvesine = new Haversine.fromDegrees(
          latitude1: pos['lat'],
          longitude1: pos['lon'],
          latitude2: base.latitude,
          longitude2: base.longitude);
      return harvesine.distance();
    }
    return null;
  }

  String toString() {
    return 'Page {$title}';
  }

  Object toJson() {
    return coordinates.toString();
  }

  String get image {
    var source = null != thumbnail ? thumbnail['source'] : null;
    if (null != source) {
//      print(source);
      return source;
    }
    return '';
  }
}
