import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truck_monitoring_apps/config/global.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';

import '../models/detail_tracking.dart';
import 'location_callback_handler.dart';

class GeoLocatorHelper {
  ReceivePort port = ReceivePort();
  LocationDto? lastLocation;
  bool isRunning = false;
  String isolateNameServer = "truck_monitoring_locator";

  Future<bool> checkStatus() async {
    isRunning = await BackgroundLocator.isServiceRunning();
    if (isRunning) {
      return await BackgroundLocator.isRegisterLocationUpdate();
    }
    return false;
  }

  Future<void> initGeolocator({Function? updateUI}) async {
    if (IsolateNameServer.lookupPortByName(isolateNameServer) != null) {
      IsolateNameServer.removePortNameMapping(isolateNameServer);
    }
    IsolateNameServer.registerPortWithName(port.sendPort, isolateNameServer);
    try {
      port.listen((message) async {
        LocationDto? locationDto =
            (message != null) ? LocationDto.fromJson(message) : null;
        if (locationDto != null && geoLocCol.items.length > 2) {
          if (geoLocCol.items[geoLocCol.items.length - 1].latitude !=
                  locationDto.latitude &&
              geoLocCol.items[geoLocCol.items.length - 1].longitude !=
                  locationDto.longitude) {
            geoLocCol.items.add(GeoLocationItem(
                latitude: locationDto.latitude,
                longitude: locationDto.longitude,
                time: locationDto.time.toString()));
          }
        } else if (locationDto != null) {
          geoLocCol.items.add(GeoLocationItem(
              latitude: locationDto.latitude,
              longitude: locationDto.longitude,
              time: locationDto.time.toString()));
        }
        if (updateUI != null) {
          printLog("Update Something : $message");
          await updateUI(message);
        } else {
          printLog("Update UI is null");
        }
      });
    } catch (e) {
      printLog("Stream Already been listen");
    }
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    printLog("Init Platform State");
    isRunning = await BackgroundLocator.isServiceRunning();
    if (!isRunning) {
      await BackgroundLocator.initialize();
    }
  }

  Future<bool> checkLocationPermission() async {
    final access = await Permission.locationAlways.status;
    switch (access) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await Permission.locationAlways.request();
        if (permission == PermissionStatus.granted) {
          return true;
        }
        return false;
      case PermissionStatus.granted:
        return true;
      default:
        return false;
    }
  }

  Future<void> onStart() async {
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            distanceFilter: 0,
            stopWithTerminate: true),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 0,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: "Truck Location Tracking",
                notificationTitle: "Truck Location Monitoring",
                notificationMsg: "Truck Location has been track in background",
                notificationBigMsg:
                    "Background location is on to keep the app uptodate with your location. this is required for main features to work properly when the app is not running.",
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  void start() async {
    if (await checkLocationPermission()) {
      if (isRunning) {
        showMessage(
            title: "Failed",
            message: "Geolocator is already running!",
            type: MessageType.error);
        return;
      }
      await onStart();
      isRunning = await BackgroundLocator.isServiceRunning();
      lastLocation = null;
    } else {
      showMessage(
          title: "Error Permission",
          message: "Location Always permission is not granted!",
          type: MessageType.error);
    }
  }

  Future<void> stop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    // IsolateNameServer.removePortNameMapping(isolateNameServer);
    // port.close();

    isRunning = await BackgroundLocator.isServiceRunning();
    printLog("Is Service Running : $isRunning");
  }
}
