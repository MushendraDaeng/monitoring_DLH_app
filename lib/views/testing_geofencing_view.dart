import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truck_monitoring_apps/utils/logger.dart';
import 'package:truck_monitoring_apps/utils/style.dart';

import '../utils/location_callback_handler.dart';

class TestGeofencingView extends StatefulWidget {
  const TestGeofencingView({super.key});

  @override
  State<TestGeofencingView> createState() => _TestGeofencingViewState();
}

class _TestGeofencingViewState extends State<TestGeofencingView> {
  final AppStyle style = AppStyle();
  late Size screen;
  ReceivePort port = ReceivePort();
  bool isRunning = false;
  LocationDto? lastLocation;

  void initGeolocator() {
    if (IsolateNameServer.lookupPortByName("truck_monitor_locator") != null) {
      IsolateNameServer.removePortNameMapping("truck_monitor_locator");
    }
    IsolateNameServer.registerPortWithName(
        port.sendPort, "truck_monitor_locator");

    port.listen((message) async {
      // await
      await updateUI(message);
    });
    initPlatformState();
  }

  Future<void> updateUI(dynamic data) async {
    LocationDto? locationDto =
        (data != null) ? LocationDto.fromJson(data) : null;
    await _updateNotificationText(locationDto);
    setState(() {
      if (data != null) {
        lastLocation = locationDto!;
      }
    });
  }

  Future<void> _updateNotificationText(LocationDto? data) async {
    if (data == null) {
      return;
    }
    await BackgroundLocator.updateNotificationText(
        title: "New Locatio Received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

  Future<void> initPlatformState() async {
    printLog("Initalizing..");
    await BackgroundLocator.initialize();
    // printLog("Initialization done");
    isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {});
    // printLog("Running $isRunning");
    // initPlatformState();
  }

  void onStop() async {
    await BackgroundLocator.unRegisterLocationUpdate();
    isRunning = await BackgroundLocator.isServiceRunning();
    setState(() {});
    printLog("Running : $isRunning");
  }

  void _onStart() async {
    if (await _checkLocationPermission()) {
      await _startLocator();
      isRunning = await BackgroundLocator.isServiceRunning();
      setState(() {
        lastLocation = null;
      });
    } else {
      showMessage(
          title: "Error",
          message: "Failed to get Permission",
          type: MessageType.error);
    }
  }

  Future<bool> _checkLocationPermission() async {
    final access = await Permission.locationAlways.status;
    switch (access) {
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await Permission.locationAlways.request();
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }

      case PermissionStatus.granted:
        return true;

      default:
        return false;
    }
  }

  Future<void> _startLocator() async {
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
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initGeolocator();
  }

  @override
  Widget build(BuildContext context) {
    screen = MediaQuery.of(context).size;
    final start = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Start'),
        onPressed: () {
          _onStart();
        },
      ),
    );
    final stop = SizedBox(
      width: double.maxFinite,
      child: ElevatedButton(
        child: Text('Stop'),
        onPressed: () {
          onStop();
        },
      ),
    );

    String msgStatus = "-";
    if (isRunning != null) {
      if (isRunning) {
        msgStatus = 'Is running';
      } else {
        msgStatus = 'Is not running';
      }
    }
    final status = Text("Status: $msgStatus");

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter background Locator'),
        ),
        body: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[start, stop, status],
            ),
          ),
        ),
      ),
    );
  }
}
