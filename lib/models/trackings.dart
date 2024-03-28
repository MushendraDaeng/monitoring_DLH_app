class Trackings {
  String? id, stopLocation;
  String driverId,
      driverName,
      truckId,
      truckPlate,
      startLocation,
      routeId,
      routeName;
  DateTime actDate, startTime;
  DateTime? stopTime;
  Trackings(
      {required this.driverId,
      required this.driverName,
      required this.truckId,
      required this.truckPlate,
      required this.startLocation,
      required this.actDate,
      required this.startTime,
      required this.routeId,
      required this.routeName,
      this.id,
      this.stopLocation,
      this.stopTime});
  factory Trackings.fromJson(dynamic json) {
    return Trackings(
        driverId: json['driver_id'],
        driverName: json['driver_name'],
        truckId: json['truck_id'] ?? '-',
        truckPlate: json['truck_plate'] ?? '-',
        startLocation:
            json['start_location'] == null || json['start_location'] == ''
                ? '-'
                : json['start_location'],
        routeId: json['route_id'],
        routeName: json['route_name'],
        actDate:
            DateTime.parse((json['act_date'] ?? DateTime.now()).toString()),
        startTime:
            DateTime.parse((json['start_time'] ?? DateTime.now()).toString()),
        id: json['id'],
        stopLocation: json['stop_location'],
        stopTime:
            DateTime.parse((json['stop_time'] ?? DateTime.now()).toString()));
  }
  Map<String, String> toMap() {
    return {
      'id': id ?? '',
      'driver_id': driverId,
      'route_id': routeId,
      'route_name': routeName,
      'driver_name': driverName,
      'truck_id': truckId,
      'truck_plate': truckPlate,
      'start_location': startLocation,
      'act_date': actDate.toString(),
      'start_time': startTime.toString(),
      'stop_time': stopTime.toString(),
      'stop_location': stopLocation ?? ''
    };
  }
}
