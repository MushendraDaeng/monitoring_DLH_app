import 'dart:convert';

import '../utils/logger.dart';

class DetailTracking {
  String? id, geolocationCol;
  String truckId, truckPlate, driverId, driverName, activityId;
  DateTime trackingDate;
  DetailTracking(
      {required this.activityId,
      required this.driverId,
      required this.driverName,
      required this.truckId,
      required this.truckPlate,
      required this.trackingDate,
      this.id,
      this.geolocationCol});

  factory DetailTracking.fromJson(dynamic json) {
    return DetailTracking(
        activityId: json['activity_id'],
        driverId: json['driver_id'],
        driverName: json['driver_name'],
        truckId: json['truck_id'],
        truckPlate: json['truck_plate'],
        trackingDate: DateTime.parse(
            (json['tracking_date'] ?? DateTime.now()).toString()),
        id: json['id'],
        geolocationCol: json['geolocation_col']);
  }
  Map<String, String> toMap() {
    return {
      'id': id ?? '',
      'driver_id': driverId,
      'driver_name': driverName,
      'truck_id': truckId,
      'truck_plate': truckPlate,
      'tracking_date': trackingDate.toString(),
      'activity_id': activityId,
      'geolocation_col': geolocationCol ?? ''
    };
  }
}

class GeoLocationItem {
  double latitude, longitude;
  String time;
  GeoLocationItem(
      {required this.latitude, required this.longitude, required this.time});
  factory GeoLocationItem.fromJson(dynamic json) {
    return GeoLocationItem(
        latitude: json['latitude'],
        longitude: json['longitude'],
        time: json['time']);
  }
  Map<String, dynamic> toMap() {
    return {"latitude": latitude, "longitude": longitude, "time": time};
  }
}

class GeoLocationCollection {
  List<GeoLocationItem> items;
  String trackingId;
  GeoLocationCollection({required this.items, required this.trackingId});
  factory GeoLocationCollection.fromJson(dynamic json) {
    List<GeoLocationItem> items = [];
    for (var item in json['items']) {
      items.add(GeoLocationItem.fromJson(item));
    }
    return GeoLocationCollection(items: items, trackingId: json['trackingId']);
  }
  Map<String, dynamic> toMap() {
    return {
      "items": jsonEncode(items
          .map((e) => {
                "latitude": e.latitude,
                "longitude": e.longitude,
                "time": e.time
              })
          .toList()),
      "trackingId": trackingId
    };
  }

  String convertToBase64() {
    var body = {
      "items": jsonEncode(items
          .map((e) => {
                "latitude": e.latitude,
                "longitude": e.longitude,
                "time": e.time
              })
          .toList()),
      "trackingId": trackingId
    };
    printLog("Items Length : ${items.length}");
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(jsonEncode(body));
    return encoded;
  }
}
