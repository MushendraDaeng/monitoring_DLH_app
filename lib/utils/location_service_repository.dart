import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:background_locator_2/location_dto.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/models/detail_tracking.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';

import 'file_manager.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'truck_monitoring_locator';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    //TODO change logs
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    printLog("$_count");
    for (var g in geoLocCol.items) {
      print("Geo Location Item : ${g.latitude}, ${g.latitude}, ${g.time}");
    }
    geoLocCol.items.clear();
    geoLocCol.trackingId = "";
    await setLogLabel("end");
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print(
        'GEO Location Item : ${geoLocCol.items.length} => $_count location in dart: ${locationDto.toString()}');
    if (_count > 1 && geoLocCol.items.length > 2) {
      if (geoLocCol.items[geoLocCol.items.length - 1].latitude !=
              locationDto.latitude &&
          geoLocCol.items[geoLocCol.items.length - 1].longitude !=
              locationDto.longitude) {
        geoLocCol.items.add(GeoLocationItem(
            latitude: locationDto.latitude,
            longitude: locationDto.longitude,
            time: locationDto.time.toString()));
      }
    } else {
      geoLocCol.items.add(GeoLocationItem(
          latitude: locationDto.latitude,
          longitude: locationDto.longitude,
          time: locationDto.time.toString()));
    }
    await setLogPosition(_count, locationDto);
    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
    _count++;
  }

  static Future<void> setLogLabel(String label) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();
    await FileManager.writeToLogFile(
        '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
  }

  static double dp(double val, int places) {
    num mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }
}
