import 'package:location/location.dart';

class LocationType {
  double latitude;
  double longitude;
  double altitude;
  double speed;
  double speedAccuracy;
  double accuracy;

  LocationType(this.latitude, this.longitude, [this.altitude]);

  LocationType.fromResult(LocationData data)
      : this.latitude = data.latitude,
        this.longitude = data.longitude,
        this.altitude = data.altitude,
        this.speed = data.speed,
        this.speedAccuracy = data.speedAccuracy,
        this.accuracy = data.accuracy;

  String toString() {
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }
}
