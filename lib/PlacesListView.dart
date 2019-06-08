import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'LocationInfoPage.dart';
import 'Page.dart';
import 'Places.dart';

class PlacesListView extends StatefulWidget {
  final Places places;

  const PlacesListView({Key key, this.places}) : super(key: key);

  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<PlacesListView> {
  @override
  Widget build(BuildContext context) {
    return LiquidPullToRefresh(
        onRefresh: () {
          print('refresh');
          return widget.places.refresh();
        },
        child: widget.places.places.length > 0
            ? ListView(shrinkWrap: true, children: getPlaceTiles())
            : ListView(shrinkWrap: true, children: [
                ListTile(
                    title: Text(
                        'Nothing interesing within ${(widget.places.radius / 1000).toStringAsFixed(3)} km nearby ¯\\_(ツ)_/¯.'
                        'Pull down to refresh'))
              ]));
  }

  List<Widget> getPlaceTiles() {
    var tiles = widget.places.places.map((Page p) {
      var distance = p.distanceTo(widget.places.currentLocation);
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
                      currentLocation: widget.places.currentLocation,
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
      title: FlatButton(
        child: Text('Load more places...'),
        onPressed: () {
          widget.places.radius *= 2;
          widget.places.refresh();
        },
      ),
      onTap: () {},
    ));
    return withDivs;
  }
}
