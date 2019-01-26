class LocationType {
  double latitude;
  double longitude;
  double altitude;
  double speed;
  double speed_accuracy;
  double accuracy;

  LocationType(this.latitude, this.longitude, [this.altitude]);

  LocationType.fromResult(Map<String, double> data)
      : this.latitude = data['latitude'],
        this.longitude = data['longitude'],
        this.altitude = data['altitude'],
        this.speed = data['speed'],
        this.speed_accuracy = data['speed_accuracy'],
        this.accuracy = data['accuracy'];

  String toString() {
    return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }
}
